{
  additions = final: _: import ../pkgs { pkgs = final; };
  flameshot = _: prev: {
    flameshot = prev.flameshot.overrideAttrs (old: {
      src = prev.pkgs.fetchFromGitHub {
        owner = "flameshot-org";
        repo = "flameshot";
        rev = "3d21e4967b68e9ce80fb2238857aa1bf12c7b905";
        sha256 = "sha256-OLRtF/yjHDN+sIbgilBZ6sBZ3FO6K533kFC1L2peugc=";
      };
      cmakeFlags = [
        "-DUSE_WAYLAND_GRIM=true"
        "-DUSE_WAYLAND_CLIPBOARD=true"
      ];
      buildInputs = old.buildInputs ++ [ prev.pkgs.libsForQt5.kguiaddons ];
    });
  };
}
