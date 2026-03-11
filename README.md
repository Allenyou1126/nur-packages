# Allen You's NUR Packages

## 警告 / Warning

这个 NUR 仓库包括了一些针对我自己使用场景定制的包。我**不保证**这些包的向后兼容性与功能稳定性。

This NUR contains packages customized for my own use. I **DO NOT** ensure that they stay backwards compatible or functionally stable.

## 如何使用 / How to use

```nix
# flake.nix
{
  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nur-allenyou = {
      url = "github:Allenyou1126/nur-packages";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, ... }@inputs: {
    nixosConfigurations.default = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      modules = [
        # 从这个仓库添加包 / Add packages from this repo
        inputs.nur-allenyou.nixosModules.setupOverlay
      ];
    };
  };
}
```

## 软件包 / Packages

如无特殊说明，所有包均只为 `x86_64-linux` 平台构建。暂无支持其他平台的计划。

If not specified otherwise, all packages are only built for the `x86_64-linux` platform. No plans to support other platforms currently.

<details>
<summary>未分类 / Uncategorized (1 package)</summary>

| 状态 / State | 路径 / Path | 包名 / Name | 版本 / Version | 描述 / Description |
| ----- | ---- | ---- | ------- | ----------- |
| 正常 / Working | `certimate` | [`certimate`](https://github.com/certimate-go/certimate) | 0.4.18 | An open-source and free self-hosted SSL certificates ACME tool, automates the full-cycle of issuance, deployment, renewal, and monitoring visually. 完全开源免费的自托管 SSL 证书 ACME 工具，申请、部署、续期、监控全流程自动化可视化，支持各大主流云厂商。 |
</details>