{ lib, pkgs, ... }:

{
  programs.helix = {
    enable = true;

    settings = {
      editor = {
        line-number = "relative";
        bufferline = "multiple";
        auto-format = true; # 保存时自动格式化
      };
    };

    # 统一使用 4 空格缩进，tab 宽度按 4 列渲染
    languages.language =
      let
        indent4 = {
          tab-width = 4;
          unit = "    ";
        };
      in
      map (name: {
        inherit name;
        indent = indent4;
        auto-format = true;
      } // lib.optionalAttrs (name == "python") {
        # Python：ty 提供 LSP，ruff 提供 lint/修复与格式化
        "language-servers" = [ "ty" "ruff" ];
        formatter = {
          command = "${pkgs.ruff}/bin/ruff";
          args = [ "format" "-" ];
        };
      } // lib.optionalAttrs (name == "nix") {
        formatter.command = "${pkgs.nixfmt-rfc-style}/bin/nixfmt";
      } // lib.optionalAttrs (name == "bash") {
        formatter = {
          command = "${pkgs.shfmt}/bin/shfmt";
          args = [ "-i" "4" ];
        };
      }) [
        "bash"
        "c"
        "cmake"
        "cpp"
        "css"
        "dockerfile"
        "go"
        "html"
        "ini"
        "java"
        "javascript"
        "json"
        "jsx"
        "lua"
        "markdown"
        "nix"
        "python"
        "rust"
        "sql"
        "toml"
        "tsx"
        "typescript"
        "yaml"
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

      # Shell
      bash-language-server

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
