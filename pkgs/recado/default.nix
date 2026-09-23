# Recado —— 自托管、多站点、Headless 的评论系统（<https://github.com/Allenyou1126/recado>）。
#
# 上游仓库自带 flake 与 Nix 打包（`nix/packages.nix`），这里把它搬进 NUR：
# 唯一实质改动是源码改用固定 rev 的 `fetchFromGitHub`（NUR 里包必须是固定输出、
# 可复现的），打包逻辑与其保持一致，方便跟进上游更新。
#
# 产物：
#
# - `recado`     —— 服务端，只含 Nitro 产物 `.output`（自包含），运行时只需要 Node.js。
# - `recado-cli` —— 运维 CLI 与数据库迁移命令，用 esbuild 打成单文件，
#                   不需要把 tsx / drizzle-kit / 几百 MB 的 node_modules 带进运行时。
#
# 迁移是**独立部署步骤**，不在应用启动流程里：`recado-migrate` 是单独的命令。
#
# 升级步骤：改 `rev` → 重新生成 `src` 哈希 → 重新生成 `pnpm-deps-hash.nix`。
{
  lib,
  stdenv,
  fetchFromGitHub,
  nodejs,
  pnpm_11,
  fetchPnpmDeps,
  pnpmConfigHook,
  esbuild,
  makeWrapper,
}:

let
  pname = "recado";
  rev = "3e7d8bc576260ab4765aa52db3f67be419a3cebf";

  # 上游 package.json 里版本号是 0.0.0（没有单一真源），用提交号标识构建：
  # store 路径里带上 rev，排查「线上跑的是哪一版」时不用再猜。
  version = "unstable-${builtins.substring 0 7 rev}";

  pnpm = pnpm_11;

  src = fetchFromGitHub {
    owner = "Allenyou1126";
    repo = "recado";
    inherit rev;
    # 上游仓库没有打 tag，只能锁 master 上的提交。
    fetchSubmodules = false;
    hash = "sha256-7NfhY12hcgXPhkELk/7rSxoTr7V844Kwic7UaMbtf0Y=";

    # 只用「构建真正会读到的文件」参与构建：文档、Docker、打包脚本本身都与产物无关，
    # 去掉它们可以让改 README / 改 flake 之类的上游提交不触发重新构建。
    # ⚠️ 不能用 basename 排除 `scripts` —— `apps/server/scripts/cli.ts` 是构建输入。
    postFetch = ''
      rm -rf \
        AGENTS.md README.md flake.lock flake.nix nix docs docker scripts \
        .githooks .specs
    '';
  };

  pnpmDeps = fetchPnpmDeps {
    inherit pname src pnpm;
    # pnpm 11+ 必须用 fetcherVersion 4（3 已被 nixpkgs 拒绝）。
    fetcherVersion = 4;
    hash = (import ./pnpm-deps-hash.nix).${stdenv.hostPlatform.system} or lib.fakeHash;
  };

  nodeTarget = "node${lib.versions.major nodejs.version}";

  # esbuild 的 ESM 输出把 CJS 依赖包成 __require，遇到 `require('events')`
  # 这类动态 require 会抛 "Dynamic require of ... is not supported"（pg 就会）。
  # 给产物注入一个真正的 require 即可。
  cjsInteropBanner = ''
    import { createRequire as __createRequire } from 'node:module'; const require = __createRequire(import.meta.url);
  '';

  common = {
    inherit src pnpmDeps;

    # pnpmConfigHook 在 configure 阶段用 pnpmDeps 里的存储执行
    # `pnpm install --offline --frozen-lockfile --ignore-scripts`，无需自己再装一次。
    nativeBuildInputs = [
      nodejs
      pnpm
      pnpmConfigHook
      makeWrapper
    ];

    env = {
      # 上游把 pnpm 版本锁在 package.json 的 `packageManager` 字段（pnpm@12.4.1），
      # 而 nixos-26.05 里 nixpkgs 只提供到 pnpm 11（12 只在 unstable 有）。沙箱里
      # 没有网络，必须关掉「照着字段去下载指定版本」的行为；nixpkgs 的
      # pnpmConfigHook 对 pnpm 11+ 也会设同样的开关。
      # lockfile 的格式是 9.0，pnpm 11 与 12 都能读，因此不必为了打包专门引入 pnpm 12。
      pnpm_config_pm_on_fail = "ignore";
      pnpm_config_trust_lockfile = "true";
      pnpm_config_update_notifier = "false";
    };

    meta = {
      description = "自托管、多站点、Headless 的评论系统";
      homepage = "https://github.com/Allenyou1126/recado";
      platforms = lib.platforms.linux;
      # 上游尚未确定许可证（package.json: UNLICENSED），因此不声明 license。
    };
  };

  # 两个可执行文件都是「node <入口文件>」：Nitro 的产物与 esbuild 的产物
  # 都不带 shebang，用 makeWrapper 固定解释器，避免依赖 PATH 里的 node。
  mkWrapper = name: entry: ''
    makeWrapper ${lib.getExe nodejs} $out/bin/${name} \
      --add-flags "${entry}" \
      --set-default NODE_ENV production
  '';
in
{
  recado = stdenv.mkDerivation (
    common
    // {
      inherit pname version;

      buildPhase = ''
        runHook preBuild
        pnpm --filter @recado/server build
        runHook postBuild
      '';

      installPhase = ''
        runHook preInstall

        mkdir -p $out/lib/recado
        # Nitro 的产物是自包含的（.output 内含运行所需的全部依赖），
        # 与上游 docker/Dockerfile 运行层拷贝的东西完全一致。
        cp -r apps/server/.output $out/lib/recado/output

        mkdir -p $out/bin
        ${mkWrapper "recado" "$out/lib/recado/output/server/index.mjs"}

        runHook postInstall
      '';

      passthru = {
        # 供调试与重新生成 pnpm-deps-hash.nix 用：
        #   nix build --impure --expr '…' -A pnpmDeps
        inherit pnpmDeps;
      };

      meta = common.meta // {
        mainProgram = "recado";
      };
    }
  );

  recado-cli = stdenv.mkDerivation (
    common
    // {
      pname = "recado-cli";
      inherit version;

      nativeBuildInputs = common.nativeBuildInputs ++ [ esbuild ];

      # 只需要 pnpmConfigHook 装好的 node_modules，没有要编译的东西。
      dontBuild = true;

      installPhase = ''
        runHook preInstall

        mkdir -p $out/lib/recado-cli

        # 迁移入口放到 packages/db 下打包，那里能解析到 drizzle-orm / pg。
        # 源文件是本目录下的 recado-migrate.mjs（上游 nix/recado-migrate.mjs 的副本）。
        cp ${./recado-migrate.mjs} packages/db/nix-migrate.mjs

        esbuild apps/server/scripts/cli.ts \
          --bundle --platform=node --format=esm --target=${nodeTarget} \
          --log-level=warning \
          --banner:js=${lib.escapeShellArg cjsInteropBanner} \
          --outfile=$out/lib/recado-cli/recado-cli.mjs

        esbuild packages/db/nix-migrate.mjs \
          --bundle --platform=node --format=esm --target=${nodeTarget} \
          --log-level=warning \
          --banner:js=${lib.escapeShellArg cjsInteropBanner} \
          --outfile=$out/lib/recado-cli/recado-migrate.mjs

        rm packages/db/nix-migrate.mjs

        # 迁移 SQL 与 journal：放在入口文件旁边，入口按 import.meta.url 找它。
        cp -r packages/db/drizzle $out/lib/recado-cli/drizzle

        mkdir -p $out/bin
        ${mkWrapper "recado-cli" "$out/lib/recado-cli/recado-cli.mjs"}
        ${mkWrapper "recado-migrate" "$out/lib/recado-cli/recado-migrate.mjs"}

        runHook postInstall
      '';

      meta = common.meta // {
        description = "Recado 运维 CLI 与数据库迁移命令";
        mainProgram = "recado-cli";
      };
    }
  );
}
