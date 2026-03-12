{
  fetchFromGitHub,
  buildGoModule,
  pkgs,
}:
let
  ui = pkgs.callPackage ./ui.nix { };
in
buildGoModule {
  pname = "certimate";
  version = "0.4.18";
  src = fetchFromGitHub ({
    owner = "certimate-go";
    repo = "certimate";
    rev = "v0.4.18";
    fetchSubmodules = false;
    sha256 = "sha256-xaH4JYD+EuKucFUH5XhOXbp+A8xNimsXKXPXj5C9w8k=";
  });
  vendorHash = "sha256-a8jSXpJ1z7jY72/lfk4fndBP1Q34IDzDWfZxGDiveQo=";
  preBuild = ''
    mkdir -p ./ui
    cp -r ${ui}/dist ./ui/dist
  '';
  env = {
    CGO_ENABLED = 0;
  };
  ldflags = [
    "-s"
    "-w"
  ];
}
