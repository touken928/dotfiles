{ config, ... }:

{
  programs.opencode = {
    enable = true;
    settings = {
      "$schema" = "https://opencode.ai/config.json";
      autoupdate = "notify"; # /nix/store 只读，无法自更新
      model = "xiaoxi/xiaoxi/deepseek-coding";
      provider = {
        xiaoxi = {
          npm = "@ai-sdk/openai-compatible";
          name = "xiaoxi";
          options = {
            baseURL = "https://njlitellm.xiaoxitech.com/v1";
            # 明文由 sops 在激活时解密，路径指向 ~/.config/sops-nix/secrets
            apiKey = "{file:${config.sops.secrets.xiaoxi_api_key.path}}";
          };
          models = {
            "xiaoxi/deepseek-coding" = { };
            "xiaoxi/GLM-coding" = { };
            "xiaoxi/deepseek-coding-ScrapingRE" = { };
          };
        };
      };
    };
  };
}
