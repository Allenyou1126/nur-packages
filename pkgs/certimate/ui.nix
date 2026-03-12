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
  npmDepsHash = "sha256-tuEfyePwlOy2/mOPdXbqJskO6IowvAP4DWg8xSZwbJw=";
  sourceRoot = "${src.name}/ui";
  nodejs = pkgs.nodejs_24;
}
