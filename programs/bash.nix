{ ... }:

{
  programs.bash.enable = true; # shellAliases 依赖 shell 模块写入 bashrc

  home.shellAliases = {
    hms = "home-manager switch --flake ~/.config/home-manager#touken@$(uname -m)-linux";
    hmu = "nix flake update --flake ~/.config/home-manager"; # 仅更新锁文件
  };
}
