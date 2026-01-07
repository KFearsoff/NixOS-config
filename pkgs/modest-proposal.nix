{
  stdenvNoCC,
  fetchurl,
}:
stdenvNoCC.mkDerivation {
  pname = "archive.org_modest_proposal";
  version = "latest";
  src = fetchurl {
    url = "https://archive.org/download/ost-english-a-modest-proposal-by-dr/A%20Modest%20Proposal%2C%20by%20Dr_djvu.txt";
    hash = "sha256-f9cOEWnUv++4SVaAfWhKC7p/AHjFuWK5bIpCqa11SUI=";
  };
  dontUnpack = true;
  installPhase = ''
    tail -n +37 $src \
      | grep -v "^www.gutenberg" \
      | grep -v "^8/8/12 " \
      | head -n 480 \
      >$out
  '';
}
