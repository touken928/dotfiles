{ ... }:

{
  programs.bash.enable = true; # shellAliases 依赖 shell 模块写入 bashrc

  home.shellAliases = {
    hms = "home-manager switch --flake ~/.config/home-manager#touken@$(uname -m)-linux";
  };
}
