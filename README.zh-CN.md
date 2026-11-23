# Nginx EL7 RPM

[English](README.md)

面向 CentOS 7.9 的非官方 `x86_64` RPM。构建使用 nginx.org 发布并签名的源码，沿用官方 `nginx-1.27.0-2.el7.ngx.src.rpm` 中的 spec、systemd 服务和默认配置。

## 下载和安装

从 [Releases](https://github.com/Sanjeever/nginx-el7-rpm/releases) 下载主 RPM、源码 RPM 和 `SHA256SUMS`。将三个文件放在同一个目录，运行 `sha256sum -c SHA256SUMS` 校验，再安装 `x86_64.rpm`。构建产物未签名。CentOS 7 的系统 OpenSSL 支持 TLS 1.2，构建未启用 HTTP/3。

全新安装后用 `systemctl start nginx` 启动。启用 SELinux 时，若在首次启动前运行 `nginx -t`，`/run/nginx.pid` 可能带有错误的标签。如果服务启动时报该文件权限错误，运行 `restorecon -v /run/nginx.pid` 后重试。

## 构建和发布

- [Publish Nginx Mainline RPM](https://github.com/Sanjeever/nginx-el7-rpm/actions/workflows/publish-mainline.yml) 每 6 小时检查 [Nginx 官方 Mainline 版本](https://nginx.org/en/download.html)。新版本通过构建和验证后，会发布标签为 `v<版本>` 的 Release。也可以在 `main` 上点击 **Run workflow** 立即检查。
- [Build EL7 RPM](https://github.com/Sanjeever/nginx-el7-rpm/actions/workflows/build-el7-rpm.yml) 可以手动构建指定版本，例如 `1.31.9`。完成后从运行详情的 **Artifacts** 下载 RPM、校验文件和构建日志。
