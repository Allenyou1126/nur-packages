{ ... }:

let
  overlays = import ./overlays;
in
{
  nixpkgs.overlays = [
    overlays.default
  ];
}
