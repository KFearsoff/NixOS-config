{
  stdenvNoCC,
  fetchurl,
}:
stdenvNoCC.mkDerivation {
  pname = "archive.org_brave_new_world";
  version = "latest";
  src = fetchurl {
    url = "https://archive.org/download/ost-english-brave_new_world_aldous_huxley/Brave_New_World_Aldous_Huxley_djvu.txt";
    hash = "sha256-6WkaO/3zQIezGzJDp4QjglikiTZTxgo0P4MEff2mdcY=";
  };
  dontUnpack = true;
  installPhase = ''
    cp $src $out
  '';
}
