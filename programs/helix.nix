{ pkgs, ... }:

{
  programs.helix = {
    enable = true;

    settings.editor = {
      line-number = "relative";
      bufferline = "multiple";
      auto-format = true; # 全局生效，无需逐语言重复
    };

    # 只保留与 Helix 25.07 内置默认不同的部分；缩进沿用各语言默认值
    languages.language = [
      {
        name = "python";
        language-servers = [ "ty" "ruff" ]; # 默认还会尝试未安装的 jedi/pylsp
      }
      {
        name = "nix";
        language-servers = [ "nil" ]; # 默认还会尝试未安装的 nixd
        formatter.command = "${pkgs.nixfmt}/bin/nixfmt"; # Helix 无默认 formatter
      }
      {
        name = "bash";
        language-servers = [ ]; # 不用 LSP，只保留格式化
        formatter = {
          command = "${pkgs.shfmt}/bin/shfmt"; # Helix 无默认 formatter
          args = [ "-i" "4" ];
        };
      }
      # 与 ~/.clang-format 的 IndentWidth 保持一致，避免输入/格式化缩进跳动
      {
        name = "c";
        indent = { tab-width = 4; unit = "    "; };
      }
      {
        name = "cpp";
        indent = { tab-width = 4; unit = "    "; };
      }
    ];

    # 语言服务器只注入 Helix 包装器的 PATH，不污染全局环境
    extraPackages = with pkgs; [
      # C/C++
      clang-tools # clangd

      # Rust
      rust-analyzer

      # Go
      gopls

      # Java
      jdt-language-server

      # Node.js / TypeScript
      typescript-language-server
      vscode-langservers-extracted # HTML / CSS / JSON / ESLint

      # Python
      ty
      ruff

      # Nix
      nil

      # 配置与文档
      taplo # TOML
      yaml-language-server
      marksman # Markdown

      # CMake
      cmake-language-server
    ];
  };
}
