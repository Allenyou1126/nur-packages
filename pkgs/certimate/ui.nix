{
  fetchFromGitHub,
  buildNpmPackage,
  pkgs,
}:

buildNpmPackage rec {
  pname = "certimate-ui";
  version = "0.4.18";
  src = fetchFromGitHub ({
    owner = "certimate-go";
    repo = "certimate";
    rev = "v0.4.18";
    fetchSubmodules = false;
    sha256 = "sha256-xaH4JYD+EuKucFUH5XhOXbp+A8xNimsXKXPXj5C9w8k=";
  });
  npmBuildFlags = [
    "--max-old-space-size=4096"
  ];
  npmDepsHash = "sha256-Lxcz0ztIn4vH+Q4WFcCqlRJOklUyyC2FvVRUqd8Da5I=";
  sourceRoot = "${src.name}/ui";
  nodejs = pkgs.nodejs_24;
}
