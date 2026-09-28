{
  buildDotnetModule,
  fetchFromGitHub,
  icu,
  libgcc,
  openssl,
  gccNGPackages,
  zlib,
  dotnetCorePackages,
  lib,
}:
let
  version = "3.0.5";
in
buildDotnetModule {
  pname = "sockseek";
  inherit version;

  src = fetchFromGitHub {
    owner = "fiso64";
    repo = "sockseek";
    rev = "v${version}";
    hash = "sha256-ao+N9HASVDTk5fh5ikTABQdNYi6czyyKW3jeyJdw+bY=";
  };

  projectFile = [
    "Sockseek.HelpGenerator/Sockseek.HelpGenerator.csproj"
    "Sockseek.Cli/Sockseek.Cli.csproj"
  ];
  nugetDeps = ./deps.json;
  runtimeDeps = [
    icu
    libgcc
    openssl
    gccNGPackages.libstdcxx
    zlib
  ];

  selfContainedBuild = true;
  dotnet-sdk = dotnetCorePackages.sdk_10_0;
  dotnet-runtime = dotnetCorePackages.runtime_10_0;
  dotnetBuildFlags = [
    "--property:PublishSingleFile=true"
    "--property:PublishTrimmed=true"
    "--property:OpenApiGenerateDocuments=false"
  ];
  executables = [ "sockseek" ];

  # FIXME: Dotnet is turbobroken with IPv6 on networks without such connectivity
  env = {
    DOTNET_SYSTEM_NET_DISABLEIPV6 = "1";
  };

  meta = {
    description = "Advanced download tool for Soulseek, soon a client";
    homepage = "https://github.com/fiso64/sockseek";
    license = lib.licenses.agpl3Plus;
    platforms = lib.platforms.unix;
  };
}
