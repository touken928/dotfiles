{ ... }:

{
  programs.opencode = {
    enable = true;
    settings.autoupdate = "notify"; # /nix/store 只读，无法自更新
  };
}
