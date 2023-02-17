#!/bin/sh -e

ask() {
	printf '%s? ' "$2"
	read -r "$1"
}

ask name "Package name"
ask desc "Package description"

mkdir "mca/$name"

cat >"mca/$name/APKBUILD" <<EOF
# Maintainer: $(git config user.name) <$(git config user.email)>
pkgname=$name
pkgdesc="$desc"
pkgver="$(date +%Y%m%d)"
pkgrel=0
url="https://example.com"
arch="any"
options="!check"
license="MIT"
depends="
EOF

printf 'Depends? (blank line to finish)\n'

while read -r line; do
	if [ -z "$line" ]; then
		break
	fi
	printf '	%s\n' "$line"
done | sort >> "mca/$name/APKBUILD"

cat >>"mca/$name/APKBUILD" <<EOF
"

package() {
	mkdir -p "\$pkgdir"
}
EOF
