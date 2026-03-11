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
    sha256 = "sha256-y7SD+czD/jK/m0LbFq7qGjwJgBIXfTNrdsA3pzgD2xE=";
  });
  vendorSha256 = "sha256-ZrwFUZDTbJx5qvloVOa5qK1ykKNkUn1hjfz0xf+8sWk=";
}
