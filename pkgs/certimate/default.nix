{
  fetchFromGitHub,
  buildGoModule,
}:

buildGoModule {
  pname = "certimate";
  version = "0.4.18";
  src = fetchFromGitHub ({
    owner = "certimate-go";
    repo = "certimate";
    rev = "v0.4.18";
    fetchSubmodules = false;
    sha256 = "sha256-3333333333333333333333333333333333333333333333333333333333333333";
  });
  vendorSha256 = "sha256-3333333333333333333333333333333333333333333333333333333333333333+8sWk=";
}
