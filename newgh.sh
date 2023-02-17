#!/bin/sh -e

if [ "$#" -lt 1 ]; then
	printf 'Specify GitHub repository.\n' >&2
	exit 1
fi

temp="$(curl -fL "https://api.github.com/repos/$1")"

filter() {
	printf '%s' "$temp" | jq -r "$@"
}

license="$(filter ".license.spdx_id")"
branch="$(filter ".default_branch")"
temp="$(curl -fL "https://api.github.com/repos/$1/commits")"
commit="$(filter ".[0].sha")"
committime="$(filter ".[0].commit.author.date")"
committime="$(printf '%s' "$committime" | sed 's/-//g')"
committime="${committime%%T*}"

cd mca
newapkbuild -l "$license" "${1##*/}-${committime}"

sed -i \
	-e "/^# Contributor.*$/d" \
	-e "s|^# Maintainer:|& $(git config user.name) <$(git config user.email)>|" \
	-e "s|^source=.*$|_rev='$commit'\nsource=\"https://github.com/$1/archive/\$_rev.tar.gz\"|" \
	-e "s|^url=.*$|url='https://github.com/$1'|" \
	-e "s|builddir=\"\$srcdir/|&${1##*/}-\$_rev|" \
	"${1##*/}/APKBUILD"

cd "${1##*/}"
abuild checksum
abuild unpack
