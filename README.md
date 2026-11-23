# Nginx EL7 RPM

在 CentOS 7.9 用户空间构建 Nginx `x86_64` RPM。源码取自 nginx.org，打包沿用官方 `nginx-1.27.0-2.el7.ngx.src.rpm` 中的 spec、systemd 服务和默认配置。

1. 打开 [Build EL7 RPM](https://github.com/Sanjeever/nginx-el7-rpm/actions/workflows/build-el7-rpm.yml)，点击 **Run workflow**。
2. 输入 Nginx 版本号，例如 `1.31.9`。
3. 构建完成后，在运行详情的 **Artifacts** 下载 `nginx-<版本>-el7-x86_64` 并解压。

产物包含主 RPM、SRPM、`SHA256SUMS` 和 `build.log`。在目标机上可先用 `sha256sum -c SHA256SUMS` 核验，再安装主 RPM。生成的 RPM 为未签名的自建包。构建使用 CentOS 7 的系统 OpenSSL，HTTPS 支持 TLS 1.2，未启用 HTTP/3。
