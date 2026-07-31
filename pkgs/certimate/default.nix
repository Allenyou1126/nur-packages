{
  fetchFromGitHub,
  buildGoModule,
  pkgs,
}:
let
  ui = pkgs.callPackage ./ui.nix { };
  version = "0.4.21";
in
buildGoModule {
  pname = "certimate";
  version = version;
  src = fetchFromGitHub ({
    owner = "certimate-go";
    repo = "certimate";
    rev = "v${version}";
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
  doCheck = false;
}
