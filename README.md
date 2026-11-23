# Nginx EL7 RPM

[简体中文](README.zh-CN.md)

Unofficial `x86_64` RPMs for CentOS 7.9, built from signed nginx.org source tarballs using the spec, systemd service, and defaults from the official `nginx-1.27.0-2.el7.ngx.src.rpm`.

## Download and install

Download the binary RPM, source RPM, and `SHA256SUMS` from [Releases](https://github.com/Sanjeever/nginx-el7-rpm/releases). With all three files in the same directory, verify them using `sha256sum -c SHA256SUMS`, then install the `x86_64.rpm` package. The built RPMs are unsigned. The system OpenSSL on CentOS 7 supports TLS 1.2, and these builds omit HTTP/3.

On a fresh installation, start the service with `systemctl start nginx`. Under SELinux, running `nginx -t` before the first start can leave `/run/nginx.pid` with the wrong label. If the service fails with a permission error on that file, run `restorecon -v /run/nginx.pid` and start the service again.

## Build and release

- [Publish Nginx Mainline RPM](https://github.com/Sanjeever/nginx-el7-rpm/actions/workflows/publish-mainline.yml) checks the [official Mainline version](https://nginx.org/en/download.html) every six hours. It builds and tests an unpublished version before creating a Release tagged `v<version>`. **Run workflow** on `main` performs the same check on demand.
- [Build EL7 RPM](https://github.com/Sanjeever/nginx-el7-rpm/actions/workflows/build-el7-rpm.yml) builds the version you enter, such as `1.31.9`. Download the RPMs, checksums, and build log from **Artifacts** on the run page.
