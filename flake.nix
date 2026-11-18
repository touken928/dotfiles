{
  description = "Unified Multi-Arch Standalone Home Manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs"; # 复用同一 nixpkgs 避免版本冲突
    };

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, sops-nix, ... }:
    let
      supportedSystems = [ "x86_64-linux" "aarch64-linux" ];

      mkHomeConfig = system:
        home-manager.lib.homeManagerConfiguration {
          pkgs = import nixpkgs {
            inherit system;
            config.allowUnfree = true; # 允许非自由软件包
          };
          modules = [ ./home.nix sops-nix.homeManagerModules.sops ];
        };
    in
    {
      # 按 "用户名@系统架构" 导出，自动匹配当前机器真实架构
      homeConfigurations = nixpkgs.lib.listToAttrs (map (system: {
        name = "touken@${system}";
        value = mkHomeConfig system;
      }) supportedSystems);
    };
}
