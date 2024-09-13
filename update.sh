#!/bin/bash

set -eu
src=/mnt/datasets/datalad/ci/git-annex/releases

# set -x
cd "$(dirname "$0")"

# helper for development
#function datalad() {
#    echo "DRY: calling datalad $*"
#}

function copy_version() {
    version="$1"
    if ! cp -L "$src/$version"/*.{deb,changes,dsc,tar.gz} neurodebian/; then
        echo "I: no Debian builds for $version"
    fi
    if ls -ld neurodebian/*.ndall* 2>/dev/null ; then
        ( cd neurodebian/; for f in *.ndall*; do mv "$f" "${f//.ndall/~ndall}"; done; )
    fi
    echo -e "dmg osx\nexe windows" | while read -r ext os; do
        p=( "$src/$version"/*."$ext" )
        if /bin/ls "${p[@]}" >& /dev/null; then
            cp "${p[@]}" "$os"/
        else
            echo "I: no ${p[*]} -- thus no build for $os. Skipped"
        fi
    done
}

if [ "$#" = 0 ]; then
    latest=$(cd "$src" && /bin/ls -1d [0-9]*.20* | sort -n | sed -e 's,/,,g' | tail -n 1 )
    current=$(cat latest-version)

    if [ "$latest" != "$current" ]; then
        echo "I: Working with the latest version $latest whenever current $current"
        copy_version "$latest"
        echo "$latest" >| latest-version
        datalad save -m "Updated to $latest from $current" -d^ ./
        datalad push --to=datalad-public
    fi
else
    for version in "$@"; do
        if /bin/ls neurodebian/git-annex*_"${version}-"*.deb &>/dev/null; then
            echo "I: $version was already copied (.deb at least). Skipping"
            continue
        fi
        echo "I: copying version $version"
        copy_version "$version"
        datalad save -m "Added version $version" -d^ ./
    done
    datalad push --to=datalad-public
fi
