{
  description = "Allen You's personal NUR repository";
  inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
  outputs =
    { self, nixpkgs }:
    let
      systems = [
        "x86_64-linux"
      ];
      forAllSystems = nixpkgs.lib.genAttrs systems;

      # 模块与平台无关，固定用 x86_64-linux 的 pkgs 作兜底实例即可 ——
      # 各模块里的包默认是从本仓库源码取的（见 modules/recado.nix）。
      moduleArgs = {
        pkgs = import nixpkgs { system = "x86_64-linux"; };
      };
    in
    {
      legacyPackages = forAllSystems (
        system:
        import ./default.nix {
          pkgs = import nixpkgs { inherit system; };
        }
      );
      packages = forAllSystems (
        system: nixpkgs.lib.filterAttrs (_: v: nixpkgs.lib.isDerivation v) self.legacyPackages.${system}
      );

      # `import ./overlays` 得到的是外层函数，这里显式调用以取出 `{ default = …; }`。
      overlays = (import ./overlays) { };

      # NUR 约定的模块出口，用法见 README：
      #   inputs.nur-allenyou.nixosModules.setupOverlay
      #   inputs.nur-allenyou.nixosModules.recado
      #
      # `setupOverlay` 就地构造，而不是放进 modules/：它要引用仓库根目录的
      # `overlays/`，而模块被复制进 Nix store 时只保证模块自己那个目录存在，
      # 模块内部的 `./overlays` 会解析成 `modules/overlays`（不存在）。
      nixosModules = {
        setupOverlay =
          { ... }:
          {
            nixpkgs.overlays = [ self.overlays.default ];
          };
      }
      // (import ./modules moduleArgs);
    };
}
