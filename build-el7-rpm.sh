#!/usr/bin/env bash
set -euo pipefail
export LC_ALL=C

version=${1:-}
if [[ ! $version =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    printf 'Enter an Nginx version such as 1.31.9.\n' >&2
    exit 2
fi

work=$(mktemp -d)
topdir="$work/rpmbuild"
template=nginx-1.27.0-2.el7.ngx.src.rpm
src="$topdir/SOURCES/nginx-$version.tar.gz"
mkdir -p "$topdir"/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS} "$work/rpmdb"
install -d -m 700 "$work/gnupg"

fetch() {
    curl -fLsS --retry 3 --connect-timeout 10 --max-time 90 -o "$2" "$1"
}

fetch "https://nginx.org/download/nginx-$version.tar.gz" "$src"
fetch "https://nginx.org/download/nginx-$version.tar.gz.asc" "$src.asc"
for key in arut pluknet sb thresh sai; do
    fetch "https://nginx.org/keys/$key.key" "$work/$key.key"
done
gpg2 --homedir "$work/gnupg" --batch --import "$work"/*.key
gpg2 --homedir "$work/gnupg" --batch --verify "$src.asc" "$src"

fetch "https://nginx.org/packages/mainline/centos/7/SRPMS/$template" "$work/$template"
fetch https://nginx.org/keys/nginx_signing.key "$work/nginx_signing.key"
rpm --dbpath "$work/rpmdb" --initdb
rpm --dbpath "$work/rpmdb" --import "$work/nginx_signing.key"
rpm --dbpath "$work/rpmdb" -Kv "$work/$template" | tee "$work/template-signature.log"
if ! grep -Eq 'Signature, key ID [[:xdigit:]]+: OK$' "$work/template-signature.log"; then
    printf 'The EL7 template has no verifiable RPM signature.\n' >&2
    exit 1
fi
rpm --dbpath "$work/rpmdb" -ivh --define "_topdir $topdir" "$work/$template"

spec="$topdir/SPECS/nginx.spec"
sed -i \
    -e "s/^%define base_version .*/%define base_version $version/" \
    -e 's/^%define base_release .*/%define base_release 1%{?dist}/' \
    -e '/^Vendor:/d' "$spec"
rpmbuild -ba --target x86_64 --define "_topdir $topdir" "$spec"

package="$topdir/RPMS/x86_64/nginx-$version-1.el7.x86_64.rpm"
source_package="$topdir/SRPMS/nginx-$version-1.el7.src.rpm"
rpm -qp --qf '%{NAME} %{VERSION}-%{RELEASE} %{ARCH}\n' "$package"
rpm -U --test "$package"
rpm -Uv "$package"
nginx -t

smoke_dir="$work/smoke"
mkdir "$smoke_dir"
cd "$smoke_dir"
cat > nginx.conf <<EOF
error_log stderr;
pid $smoke_dir/nginx.pid;
events { worker_connections 32; }
http {
    access_log off;
    server {
        listen 127.0.0.1:18080;
        root /usr/share/nginx/html;
    }
}
EOF

nginx -c "$smoke_dir/nginx.conf"
http_code=$(curl -fsS --max-time 10 -o response.html -w '%{http_code}' http://127.0.0.1:18080/)
printf 'Loopback HTTP status: %s\n' "$http_code"
test "$http_code" = 200
cmp response.html /usr/share/nginx/html/index.html
nginx -s quit -c "$smoke_dir/nginx.conf"

cp "$package" "$source_package" /out/
cd /out
sha256sum "${package##*/}" "${source_package##*/}" | tee SHA256SUMS
