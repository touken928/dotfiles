{ pkgs, ... }:

{
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
}
