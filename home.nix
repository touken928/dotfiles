{ pkgs, ... }:

{
  home.username = "touken";
  home.homeDirectory = "/home/touken";
  home.stateVersion = "26.11"; # 兼容性基准，一旦设定不再调高

  targets.genericLinux.enable = true; # 非 NixOS 下由 HM 设置 NIX_PATH 等环境变量
  programs.bash.enable = true; # shellAliases 依赖 shell 模块写入 bashrc
  home.shellAliases = {
    hms = "home-manager switch --flake ~/.config/home-manager#touken@$(uname -m)-linux";
    hmu = "nix flake update --flake ~/.config/home-manager"; # 仅更新锁文件
  };

  home.packages = with pkgs; [
    micro

    # C/C++ 工具链
    stdenv.cc # 包装后的 GCC + Binutils + glibc 头文件，优于裸 gcc
    gnumake
    cmake
    ninja
    pkg-config
    conan

    # 调试与静态分析
    gdb
    clang-tools # clangd / clang-format / clang-tidy

    # Python
    uv # 包管理、虚拟环境与解释器版本管理
    ruff # Linter 与格式化
    ty # 类型检查器，同时提供 LSP
  ];

  # 供 `uv tool install` 装入的独立工具使用
  home.sessionPath = [ "$HOME/.local/bin" ];

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
    settings.autoupdate = "notify"; # /nix/store 只读，无法自更新
  };

  # 每周清理 7 天前的旧代际与无用缓存
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  programs.home-manager.enable = true;
}
