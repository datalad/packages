#!/bin/bash

set -eu
src=/mnt/datasets/datalad/ci/git-annex/releases

# set -x
cd "$(dirname "$0")"

latest=$(cd "$src" && /bin/ls -1d [0-9]*.20* | sort -n | sed -e 's,/,,g' | tail -n 1 )
current=$(cat latest-version)

if [ "$latest" != "$current" ]; then
    cp -L "$src/$latest"/*.{deb,changes,dsc,tar.gz} neurodebian/
    ( cd neurodebian/; for f in *.ndall*; do mv "$f" "${f//.ndall/~ndall}"; done; )
    echo -e "dmg osx\nexe windows" | while read -r ext os; do
        p="$src/$latest"/*.$ext
        if /bin/ls $p >& /dev/null; then
            cp "$p" "$os"/
        else
            echo "I: no $p -- thus no build for $os. Skipped"
        fi
    done
    echo "$latest" >| latest-version
    datalad save -m "Updated to $latest from $current" -d^ ./
    datalad push --to=datalad-public
fi

