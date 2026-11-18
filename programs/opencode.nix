{ config, ... }:

{
  programs.opencode = {
    enable = true;
    settings = {
      "$schema" = "https://opencode.ai/config.json";
      update = "notify"; # /nix/store 只读，无法自更新
      model = "xiaoxi/xiaoxi/deepseek-coding";

      # DeepSeek 使用内置提供方目录，仅需补充密钥
      providers.deepseek.settings.apiKey = "{file:${config.sops.secrets.deepseek_api_key.path}}";

      providers.xiaoxi = {
        name = "xiaoxi";
        package = "aisdk:@ai-sdk/openai-compatible";
        settings = {
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
}
