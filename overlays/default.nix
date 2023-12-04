{
  additions = final: _: import ../pkgs {pkgs = final;};
  luasnip = _: prev: {
    vimPlugins = prev.vimPlugins.extend (_: prev': {
      luasnip = prev'.luasnip.overrideAttrs (_: {
        pname = "LuaSnip";
      });
    });
  };
  LazyVim = _: prev: {
    vimPlugins = prev.vimPlugins.extend (_: prev': {
      LazyVim = prev'.LazyVim.overrideAttrs (_: {
        version = "10.8.2";
        src = prev.pkgs.fetchFromGitHub {
          owner = "LazyVim";
          repo = "LazyVim";
          rev = "879e29504d43e9f178d967ecc34d482f902e5a91";
          sha256 = "sha256-f+WPP74x9xMVSONz9m4nC4ygcO6axY1ztZHlRh3bbmM=";
        };
      });
    });
  };
}
