{ pkgs, ... }:

{
  certimate = pkgs.callPackage ./certgs/certimate { };
}
