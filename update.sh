#!/bin/bash

set -eu
src=/mnt/datasets/datalad/ci/git-annex/releases/

# set -x
cd $(dirname $0)

latest=$(cd "$src" && /bin/ls -1d *.20* | sort -n | sed -e 's,/,,g' | tail -n 1 )
current=$(cat latest-version)

if [ $latest != "$current" ]; then
    cp -L "$src/$latest"/*.{deb,changes,dsc,tar.gz} neurodebian/
    ( cd neurodebian/; for f in *.ndall*; do mv "$f" "${f//.ndall/~ndall}"; done; )
    cp -L "$src/$latest"/*.dmg osx/
    cp -L "$src/$latest"/*.exe windows/
    echo "$latest" >| latest-version
    datalad save -m "Updated to $latest from $current" -d^ ./
    datalad push --to=datalad-public
fi

