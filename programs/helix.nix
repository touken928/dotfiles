{ lib, pkgs, ... }:

{
  programs.helix = {
    enable = true;

    settings.editor = {
      line-number = "relative";
      bufferline = "multiple";
      auto-format = true; # 总开关；还需语言级 auto-format 才会生效
    };

    # Helix 的 auto-format 是两层开关：editor.auto-format 只是总闸，
    # 语言级 auto-format 默认 false，必须逐语言显式开启。
    # 缩进沿用 Helix 内置默认值，仅 C/C++ 与 clang-format 的 IndentWidth 对齐。
    languages.language =
      let
        indent4 = {
          tab-width = 4;
          unit = "    ";
        };
      in
      map (name: {
        inherit name;
        auto-format = true;
      } // lib.optionalAttrs (name == "python") {
        language-servers = [ "ty" "ruff" ]; # 默认还会尝试未安装的 jedi/pylsp
      } // lib.optionalAttrs (name == "nix") {
        language-servers = [ "nil" ]; # 默认还会尝试未安装的 nixd
        formatter.command = "${pkgs.nixfmt}/bin/nixfmt"; # Helix 无默认 formatter
      } // lib.optionalAttrs (name == "bash") {
        language-servers = [ ]; # 不用 LSP，只保留格式化
        formatter = {
          command = "${pkgs.shfmt}/bin/shfmt"; # Helix 无默认 formatter
          args = [ "-i" "4" ];
        };
      } // lib.optionalAttrs (name == "c" || name == "cpp") {
        indent = indent4;
      }) [
        "bash"
        "c"
        "cpp"
        "css"
        "go"
        "html"
        "java"
        "javascript"
        "json"
        "nix"
        "python"
        "rust"
        "toml"
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
