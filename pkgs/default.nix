{ pkgs, ... }:

let
  # 多个包的目录（返回 `{ <name> = <derivation>; ... }`）
  recado = pkgs.callPackage ./recado { };
in
{
  certimate = pkgs.callPackage ./certimate { };

  inherit (recado) recado recado-cli;
}
