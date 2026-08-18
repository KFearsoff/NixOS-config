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
  syncplay = _: prev: {
    syncplay = prev.syncplay.overridePythonAttrs (_: rec {
      version = "1.7.6";

      src = prev.fetchFromGitHub {
        owner = "Syncplay";
        repo = "syncplay";
        tag = "v${version}";
        sha256 = "sha256-DXkigo3XzR9G0g1egte96LEynSHyfhW7PjVG8i2r8Lc=";
      };
    });
  };
}
