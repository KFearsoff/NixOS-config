{
  lib,
  stdenvNoCC,
  fetchurl,
  autoPatchelfHook,
  libXcursor,
  libXcomposite,
  libXdamage,
  libXext,
  libXinerama,
  libXrandr,
  freetype,
  fontconfig,
}:
stdenvNoCC.mkDerivation {
  pname = "myteam";
  version = "1.0";

  dontBuild = true;
  installPhase = ''
    install -D myteam $out/bin/myteam  # produce $out
  '';
  setSourceRoot = "sourceRoot=$(pwd)"; # workaround for "unpacker appears to have produced no directories"

  src = fetchurl {
    url = "https://hb.bizmrg.com/myteam-www/mail.ru/linux/x64/myteam.tar.xz";
    sha256 = "sha256-F3Svf/lvjmON10JSjBAGqyUu9LM1JsJrmT+wTi1UJzw=";
  };

  nativeBuildInputs = [
    autoPatchelfHook
    libXcursor
    libXcomposite
    libXdamage
    libXext
    libXinerama
    libXrandr
    freetype
    fontconfig
  ];
}
