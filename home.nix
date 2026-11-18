{ pkgs, ... }:

{
  imports = [ ./programs ./modules ];

  home.username = "touken";
  home.homeDirectory = "/home/touken";
  home.stateVersion = "26.11"; # 兼容性基准，一旦设定不再调高

  targets.genericLinux.enable = true; # 非 NixOS 下由 HM 设置 NIX_PATH 等环境变量

  home.packages = with pkgs; [
    micro

    # 密钥管理
    sops # 编辑 secrets/ 下的加密文件

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

    # Java
    jdk21
    maven
    gradle

    # Node.js
    nodejs
    pnpm

    # Go
    go

    # Rust
    rustc
    cargo
    clippy
    rustfmt
  ];

  # clangd / clang-format 的全局默认风格；项目内的 .clang-format 仍会优先
  home.file.".clang-format".source = ./files/.clang-format;

  # 仅显式声明必须跟随 /nix/store 哈希变化的路径
  home.sessionVariables = {
    JAVA_HOME = "${pkgs.jdk21}";
    PNPM_HOME = "$HOME/.local/share/pnpm";
    EDITOR = "micro"; # 默认编辑器：yazi opener、git、crontab 等均读取此变量
    VISUAL = "micro";
  };

  # 将各语言自行安装的全局 CLI 工具目录统一纳入 PATH
  home.sessionPath = [
    "$HOME/.local/bin" # uv tool / 用户级脚本
    "$HOME/.local/share/pnpm" # pnpm add -g
    "$HOME/go/bin" # go install
    "$HOME/.cargo/bin" # cargo install
  ];

  # 每周清理 7 天前的旧代际与无用缓存
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };
}
