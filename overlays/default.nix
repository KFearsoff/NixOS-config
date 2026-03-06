{
  additions = final: _: import ../pkgs { pkgs = final; };
  statix = _: prev: {
    statix = prev.statix.overrideAttrs (_: rec {
      src = prev.fetchFromGitHub {
        owner = "oppiliappan";
        repo = "statix";
        rev = "43681f0da4bf1cc6ecd487ef0a5c6ad72e3397c7";
        hash = "sha256-LXvbkO/H+xscQsyHIo/QbNPw2EKqheuNjphdLfIZUv4=";
      };

      cargoDeps = prev.rustPlatform.importCargoLock {
        lockFile = src + "/Cargo.lock";
        allowBuiltinFetchGit = true;
      };
    });
  };
  jj-pre-push = _: prev: {
    jj-pre-push = prev.jj-pre-push.overrideAttrs (
      _:
      let
        version = "0.3.4";
      in
      {
        inherit version;
        src = prev.fetchFromGitHub {
          owner = "acarapetis";
          repo = "jj-pre-push";
          tag = "v${version}";
          hash = "sha256-sj1JM2gcwTRMeEXSozI73LCwxSf69t4u/SmovV7Cyeg=";
        };
      }
    );
  };
}
