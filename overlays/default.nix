{
  additions = final: _: import ../pkgs {pkgs = final;};
  luasnip = _: prev: {
    vimPlugins = prev.vimPlugins.extend (_: prev': {
      luasnip = prev'.luasnip.overrideAttrs (_: {
        pname = "LuaSnip";
      });
    });
  };
}
