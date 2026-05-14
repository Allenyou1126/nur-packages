{ pkgs, ... }:

{
  certimate = pkgs.callPackage ./certimate { };
}
