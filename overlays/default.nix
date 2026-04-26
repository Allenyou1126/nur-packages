{ ... }:

{
  default = final: prev: {
    allenyou-nur = import ../pkgs { pkgs = prev; };
  };
}
