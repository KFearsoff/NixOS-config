{
  additions = final: _: import ../pkgs { pkgs = final; };
  statix = _: prev: {
    statix = prev.statix.overrideAttrs (_: rec {
      src = prev.fetchFromGitHub {
        owner = "oppiliappan";
        repo = "statix";
        rev = "f76adab8920438c39edbf3463b7a7150f9875617";
        sha256 = "sha256-g1fFexvaHiW4qc3XfVaoqoCe2mp1yeaDG4wgaDgcuGM=";
      };

      cargoDeps = prev.rustPlatform.fetchCargoVendor {
        inherit src;
        hash = "sha256-jiMv28kSqCfaYnVsE/q/EtaPmSrANvJYjI9FQ2+Biz8=";
      };
    });
  };
}
