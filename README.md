# Allen You's NUR Packages

## 警告 / Warning

这个 NUR 仓库包括了一些针对我自己使用场景定制的包。我**不保证**这些包的向后兼容性与功能稳定性。

This NUR contains packages customized for my own use. I **DO NOT** ensure that they stay backwards compatible or functionally stable.

## 如何使用 / How to use

```nix
# flake.nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";
    nur-allenyou = {
      url = "github:Allenyou1126/nur-packages";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations.default = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        # 从这个仓库添加包 / Add packages from this repo
        inputs.nur-allenyou.nixosModules.setupOverlay
      ];
    };
  };
}
```

## 软件包 / Packages

如无特殊说明，所有包均只为 `x86_64-linux` 平台构建。暂无支持其他平台的计划。

If not specified otherwise, all packages are only built for the `x86_64-linux` platform. No plans to support other platforms currently.

<details>
<summary>评论系统 / Comment System (2 packages)</summary>

| 状态 / State | 路径 / Path | 包名 / Name | 版本 / Version | 描述 / Description |
| ----- | ---- | ---- | ------- | ----------- |
| 可用 / Available | `recado` | [`recado`](https://github.com/Allenyou1126/recado) | unstable-85eb134 | 自托管、多站点、Headless 的评论系统，服务端产物（自包含 `.output`，运行时只需要 Node.js）。Self-hosted, multi-site, headless comment system — server artifact. |
| 可用 / Available | `recado-cli` | [`recado-cli`](https://github.com/Allenyou1126/recado) | unstable-85eb134 | Recado 运维 CLI（`recado-cli`）与数据库迁移命令（`recado-migrate`）。Operational CLI and database migration command. |
</details>

<details>
<summary>未分类 / Uncategorized (1 package)</summary>

| 状态 / State | 路径 / Path | 包名 / Name | 版本 / Version | 描述 / Description |
| ----- | ---- | ---- | ------- | ----------- |
| 可用 / Available | `certimate` | [`certimate`](https://github.com/certimate-go/certimate) | 0.4.18 | An open-source and free self-hosted SSL certificates ACME tool, automates the full-cycle of issuance, deployment, renewal, and monitoring visually. 完全开源免费的自托管 SSL 证书 ACME 工具，申请、部署、续期、监控全流程自动化可视化，支持各大主流云厂商。 |
</details>

## Recado 部署 / Recado deployment

### 用 NixOS 模块（推荐）

```nix
{
  imports = [
    inputs.nur-allenyou.nixosModules.setupOverlay  # 让 pkgs.allenyou-nur.* 可用
    inputs.nur-allenyou.nixosModules.recado        # services.recado
  ];

  services.recado = {
    enable = true;
    settings = {
      OIDC_ISSUER_URL = "https://id.example.com";
      OIDC_CLIENT_ID = "recado";
      OIDC_REDIRECT_URI = "https://comments.example.com/auth/callback";
      OIDC_ROLE_PREFIX = "recado";
      PUBLIC_BASE_URL = "https://comments.example.com";
    };
    # 🔑 密钥不进 Nix store（store 全局可读）：用 sops-nix / agenix 生成这个文件，
    #    至少要有 DATABASE_URL、SESSION_SECRET、SECRETS_KEY、OIDC_CLIENT_SECRET。
    environmentFile = "/run/secrets/recado.env";
    database.createLocally = true;   # 可选：在本机跑 PostgreSQL
  };
}
```

`services.recado.package` / `cliPackage` 默认就取本仓库的 `recado` / `recado-cli`，
不需要额外配置。

> ⚠️ 迁移是**独立步骤**，不会随服务启动自动执行。升级后先
> `systemctl start recado-migrate`，再 `systemctl restart recado`。

### 不用 NixOS

```bash
nix build github:Allenyou1126/nur-packages#recado      # → result/bin/recado
nix build github:Allenyou1126/nur-packages#recado-cli  # → result/bin/{recado-cli,recado-migrate}
```

完整的环境变量清单、OIDC Provider 配置与反向代理要求见上游
[`docs/deployment.md`](https://github.com/Allenyou1126/recado/blob/master/docs/deployment.md)。
