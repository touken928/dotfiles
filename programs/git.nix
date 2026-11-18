{ ... }:

{
  programs.git = {
    enable = true;
    settings = {
      user.name = "touken";
      user.email = "touken928@foxmail.com";
      init.defaultBranch = "main";
    };
  };
}
