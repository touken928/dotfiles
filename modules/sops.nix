{ config, ... }:

{
  # sops-nix：密钥以加密形式存入仓库，激活时解密到 ~/.config/sops-nix/secrets
  sops = {
    # 所有密钥默认从此文件读取
    defaultSopsFile = ./secrets.yaml;

    # 独立的 age 身份文件，放在仓库之外；sops 与 sops-nix 共用该默认路径
    # 生成：age-keygen -o ~/.config/sops/age/keys.txt
    # 公钥（age1...）填入仓库根目录的 .sops.yaml
    age.keyFile = "${config.home.homeDirectory}/.config/sops/age/keys.txt";

    # 新增密钥：先 sops secrets.yaml 写入键值，再在此声明
    # secrets."example/api-key" = {
    #   path = "${config.home.homeDirectory}/.config/example/api-key";
    #   mode = "0400";
    # };

    # OpenCode 的 xiaoxi 提供方 API Key
    secrets."xiaoxi_api_key" = { };
  };
}
