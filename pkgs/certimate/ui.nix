{
  fetchFromGitHub,
  buildNpmPackage,
  pkgs,
}:
let
  pkg_version = "0.4.18";
in
buildNpmPackage rec {
  pname = "certimate-ui";
  version = pkg_version;
  src = fetchFromGitHub ({
    owner = "certimate-go";
    repo = "certimate";
    rev = "v${pkg_version}";
    fetchSubmodules = false;
    sha256 = "sha256-xaH4JYD+EuKucFUH5XhOXbp+A8xNimsXKXPXj5C9w8k=";
  });
  env = {
    NODE_OPTIONS = "--max-old-space-size=4096";
  };
  npmDepsHash = "sha256-Lxcz0ztIn4vH+Q4WFcCqlRJOklUyyC2FvVRUqd8Da5I=";
  sourceRoot = "${src.name}/ui";
  nodejs = pkgs.nodejs_24;
  dontNpmInstall = true;
  installPhase = ''
    mkdir -p $out/dist
    cp -r dist/* $out/dist/
  '';
}
