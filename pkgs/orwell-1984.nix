{
  stdenvNoCC,
  fetchurl,
}:
stdenvNoCC.mkDerivation {
  pname = "archive.org_1984.txt";
  version = "latest";
  src = fetchurl {
    url = "https://archive.org/download/GeorgeOrwells1984/1984_djvu.txt";
    hash = "sha256-9R1PTa8yDtkfH+4rU5BF62ee73irhd3VYX1QB5KU+ZU=";
  };
  dontUnpack = true;
  installPhase = ''
    grep -v "Free eBooks at Planet eBook.com" $src \
      >$out
  '';
}
