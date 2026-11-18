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

  programs.yazi = {
    enable = true; # 同时注入 bash 集成，退出后停在最后浏览的目录

    # 预览与跳转依赖只进 yazi 包装器的 PATH，不污染全局环境
    extraPackages = with pkgs; [
      ffmpeg # 视频缩略图
      _7zz # 压缩包
      poppler-utils # PDF（pdftoppm）
      imagemagick # 图片缩放
      chafa # 无 Kitty/Sixel 协议时的字符画预览
      fd # 文件搜索
      ripgrep # 内容搜索
      fzf # 模糊查找
      zoxide # 目录跳转
      jq # JSON 预览
    ];

    settings = {
      mgr = {
        ratio = [ 1 3 4 ];
        show_hidden = true;
      };
      preview = {
        wrap = "yes";
      };
    };

    # nixpkgs 已随 flake.lock 固定了插件版本，无需额外引入 yazi-rs/plugins 输入
    plugins.toggle-pane = pkgs.yaziPlugins.toggle-pane;

    keymap.mgr.prepend_keymap = [
      {
        on = "T";
        run = "plugin toggle-pane max-preview";
        desc = "Maximize or restore preview pane";
      }
    ];
  };

  # 每周清理 7 天前的旧代际与无用缓存
  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 7d";
  };

  programs.home-manager.enable = true;
}
