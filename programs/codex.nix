{ ... }:

{
  programs.codex = {
    enable = true;
    # 认证通过 `codex login`（OAuth），凭据由 Codex 自行管理
  };
}
