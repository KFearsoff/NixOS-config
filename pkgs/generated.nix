{fetchFromGitHub}: _: prev: {
  nvim-treesitter = prev.nvim-treesitter.overrideAttrs (_: {
    version = "2023-05-21";
    src = fetchFromGitHub {
      owner = "nvim-treesitter";
      repo = "nvim-treesitter";
      rev = "f2778bd1a28b74adf5b1aa51aa57da85adfa3d16";
      sha256 = "1jn0dhzp9yjy6f4qgf6khv8xwpzvns30q5g69jb5bpxg900szjr1";
    };
  });
}
