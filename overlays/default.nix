{ ... }:

{
  # 用 fixed point 里的 `final` 去 callPackage 会陷入无限递归：
  # 本仓库的包都经过 `pkgs.callPackage`，参数再从**应用 overlay 之后**的
  # pkgs 里取，于是求值 allenyou-nur.<包> 又要先求值 allenyou-nur 自己。
  # 用 `prev`（应用本 overlay 之前的 pkgs）打断这个环：
  # `nixpkgs.overlays = [ … ]` 与 `pkgs.extend …` 两种用法都因此可用。
  default = final: prev: {
    allenyou-nur = import ../pkgs { pkgs = prev; };
  };
}
