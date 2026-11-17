{ pkgs, ... }:

{
  home.username = "touken";
  home.homeDirectory = "/home/touken";
  home.stateVersion = "26.11"; # 状态目录兼容性基准版本，设定后勿改

  targets.genericLinux.enable = true; # 在非 NixOS 上自动接管 PATH 与环境变量
  programs.bash.enable = true; # 接管 bashrc 以注入上述 shellAliases（若用 zsh 则改为 programs.zsh.enable = true）
  # 快捷管理别名：hms 切换生效，hmu 仅更新锁文件
  home.shellAliases = {
    hms = "home-manager switch --flake ~/.config/home-manager#touken@$(uname -m)-linux";
    hmu = "nix flake update --flake ~/.config/home-manager";
  };


  home.packages = with pkgs; [
    micro
  ];

  programs.git = {
    enable = true;
    settings = {
      user.name = "touken";
      user.email = "touken928@foxmail.com";
      init.defaultBranch = "main";
    };
  };

  programs.opencode = {
    enable = true;
    settings.autoupdate = "notify"; # 避免直接写入只读的 /nix/store
  };

  # 每周自动清理超过 7 天的旧代际与无用缓存
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  programs.home-manager.enable = true; # 接管自身 CLI
}
