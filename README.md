# Home Manager Configuration

一套基于 Nix Flakes 与 Standalone Home Manager 的跨平台声明式开发环境配置，统一管理多语言工具链与基础设置，实现在不同 Linux 发行版之间的一键环境同步与开箱即用。

## 环境要求

- Linux 系统（`x86_64-linux` 或 `aarch64-linux`，支持 NixOS 与 Debian/Ubuntu）
- 已安装 Nix。NixOS 在 `configuration.nix` 中启用：

  ```nix
  nix.settings.experimental-features = [ "nix-command" "flakes" ];
  programs.nix-ld.enable = true;
  ```

  非 NixOS 在 `/etc/nix/nix.conf` 中添加：

  ```ini
  experimental-features = nix-command flakes
  ```

- 已备份 `age` 解密私钥（见下文「快速部署」）

## 快速部署

1. **导入 `age` 解密私钥**（用于自动解密仓库内的 `secrets.yaml`）：

   ```bash
   mkdir -p ~/.config/sops/age
   # 将备份的 keys.txt 放入 ~/.config/sops/age/keys.txt
   chmod 600 ~/.config/sops/age/keys.txt
   ```

2. **克隆仓库并应用配置**：

   ```bash
   nix run nixpkgs#git -- clone git@github.com:touken928/dotfiles.git ~/.config/home-manager
   cd ~/.config/home-manager
   nix run home-manager/master -- switch --flake ".#touken@$(uname -m)-linux"
   ```

   > 若系统已安装 `git`，也可直接使用 `git clone`。首次切换生效后，日常更新可直接使用内置别名 `hms` 切换配置。

## 目录结构

```text
.
├── flake.nix          # Flake 入口，导出 touken@<arch>-linux
├── home.nix           # 用户信息、软件包、会话变量
├── secrets.yaml       # sops 加密后的密钥（密文）
├── .sops.yaml         # sops 收件人规则
├── files/             # 静态资产
├── modules/           # 非 programs 模块
└── programs/          # 各 programs.* 独立模块
```

## 密钥管理

仓库使用 `sops-nix` + `age` 加密存储所有 API Key 与敏感凭证（`secrets.yaml`），明文只在激活时写入 `~/.config/sops-nix/secrets/`。

### 编辑或新增凭证

```bash
cd ~/.config/home-manager
sops secrets.yaml
```

在打开的 YAML 中加入键值，例如：

```yaml
deepseek_api_key: sk-xxxxxxxx
```

保存后自动重新加密。随后在 `modules/sops.nix` 中声明该密钥，才能生成对应文件：

```nix
sops.secrets."deepseek_api_key" = { };
```

再执行 `hms`。明文路径为 `~/.config/sops-nix/secrets/deepseek_api_key`（权限 `0400`），配置中用 `config.sops.secrets."deepseek_api_key".path` 引用即可。例如 OpenCode 通过 `{file:...}` 读取：

```nix
apiKey = "{file:${config.sops.secrets.deepseek_api_key.path}}";
```

### 修改 / 轮换主密钥

生成新的 `age` 身份，更新 `.sops.yaml` 公钥并重加密 `secrets.yaml`（全程无明文落盘）：

```bash
cd ~/.config/home-manager
nix shell nixpkgs#age nixpkgs#sops -c bash -c '
  set -euo pipefail
  NEW_KEY=~/.config/sops/age/keys.new.txt
  age-keygen -o "$NEW_KEY"
  NEW_PUB=$(age-keygen -y "$NEW_KEY")
  sed -i "s/age1[a-z0-9]*/$NEW_PUB/" .sops.yaml
  sops updatekeys -y secrets.yaml
  mv -f "$NEW_KEY" ~/.config/sops/age/keys.txt
  chmod 600 ~/.config/sops/age/keys.txt
'
```

> 轮换后请立即备份新的 `~/.config/sops/age/keys.txt`；旧私钥在 `sops updatekeys` 成功后即失效。

## 更新依赖

更新全部输入（`flake.lock`）：

```bash
cd ~/.config/home-manager
nix flake update
hms
```

仅更新单个输入，例如 `nixpkgs`：

```bash
nix flake update nixpkgs
hms
```

> 更新后若出现兼容性问题，可用 `git checkout flake.lock` 回滚，再执行 `hms`。
