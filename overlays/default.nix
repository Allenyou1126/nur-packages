{ pkgs, ... }:

{
  default = final: prev: {
    allenyou-nur = import ../pkgs { inherit pkgs; };
  };
}
