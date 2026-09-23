{ ... }:

# `setupOverlay` 不在这里定义：它要用到仓库根目录的 `overlays/`，而模块被复制进
# Nix store 时只保证**本目录**存在，`./overlays` 会解析到 `modules/overlays` 这个
# 不存在的路径。因此它由 `flake.nix` 直接构造（那里路径是仓库根）。
{
  recado = import ./recado.nix;
}
