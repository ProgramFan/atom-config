#!/bin/bash

# only proceed script when started not by pull request (PR)
if [ $TRAVIS_PULL_REQUEST == "true" ]; then
    echo "this is PR, exiting"
    exit 0
fi

# enable error reporting to the console
set -e

# check if we need package rebuild/update
VERSION_CHANGED=0
if [ $(git diff --name-only ${TRAVIS_COMMIT_RANGE} | grep "VERSION" | wc -l) -ge 1 ]; then
  VERSION_CHANGED=1
  echo "VERSION changed, need package update."
fi
LIST_CHANGED=0
if [ $(git diff --name-only ${TRAVIS_COMMIT_RANGE} | grep "atom-package-list.txt" | wc -l) -ge 1 ]; then
  LIST_CHANGED=1
  echo "atom-package-list.txt changed, need package update."
fi
NEED_PACKAGE_UPDATE=0
if [ $(($VERSION_CHANGED + $LIST_CHANGED)) -ge 1 ]; then
  NEED_PACKAGE_UPDATE=1
  echo "Package update scheduled."
fi

# only update config if not package update is needed
if [ $NEED_PACKAGE_UPDATE -eq 0 ]; then
  echo "No package update is needed, exit"
  exit
fi

# download atom binary and export paths
echo "Downloading latest Atom release..."
ATOM_CHANNEL="${ATOM_CHANNEL:=stable}"
if [ "$TRAVIS_OS_NAME" = "osx" ]; then
    curl -s -L "https://atom.io/download/mac?channel=$ATOM_CHANNEL" \
      -H 'Accept: application/octet-stream' \
      -o "atom.zip"
    mkdir atom
    unzip -q atom.zip -d atom
    if [ "$ATOM_CHANNEL" = "stable" ]; then
      export ATOM_APP_NAME="Atom.app"
      export ATOM_SCRIPT_NAME="atom.sh"
      export ATOM_SCRIPT_PATH="./atom/${ATOM_APP_NAME}/Contents/Resources/app/atom.sh"
    else
      export ATOM_APP_NAME="Atom ${ATOM_CHANNEL}.app"
      export ATOM_SCRIPT_NAME="atom-${ATOM_CHANNEL}"
      export ATOM_SCRIPT_PATH="./atom-${ATOM_CHANNEL}"
      ln -s "./atom/${ATOM_APP_NAME}/Contents/Resources/app/atom.sh" "${ATOM_SCRIPT_PATH}"
    fi
    export PATH="$PWD/atom/${ATOM_APP_NAME}/Contents/Resources/app/apm/bin:$PATH"
    export ATOM_PATH="./atom"
    export APM_SCRIPT_PATH="./atom/${ATOM_APP_NAME}/Contents/Resources/app/apm/node_modules/.bin/apm"
else
    curl -s -L "https://atom.io/download/deb?channel=$ATOM_CHANNEL" \
      -H 'Accept: application/octet-stream' \
      -o "atom.deb"
    /sbin/start-stop-daemon --start --quiet --pidfile \
      /tmp/custom_xvfb_99.pid --make-pidfile --background --exec \
      /usr/bin/Xvfb -- :99 -ac -screen 0 1280x1024x16
    export DISPLAY=":99"
    dpkg-deb -x atom.deb "$HOME/atom"
    if [ "$ATOM_CHANNEL" = "stable" ]; then
      export ATOM_SCRIPT_NAME="atom"
      export APM_SCRIPT_NAME="apm"
    else
      export ATOM_SCRIPT_NAME="atom-$ATOM_CHANNEL"
      export APM_SCRIPT_NAME="apm-$ATOM_CHANNEL"
    fi
    export ATOM_SCRIPT_PATH="$HOME/atom/usr/bin/$ATOM_SCRIPT_NAME"
    export APM_SCRIPT_PATH="$HOME/atom/usr/bin/$APM_SCRIPT_NAME"
fi


echo "Using Atom version:"
"$ATOM_SCRIPT_PATH" -v
echo "Using APM version:"
"$APM_SCRIPT_PATH" -v

INSTALL_PACKAGES="$(sed -e 's/#.*//g' ./atom-package-list.txt)"

if [ "$INSTALL_PACKAGES" != "none" ]; then
  echo "Installing atom packages ..."
  for pack in $INSTALL_PACKAGES ; do
    "$APM_SCRIPT_PATH" install $pack
  done
fi

echo "Uploading packages ..."
echo "  Cloning remote repository ..."
branch=release-${TRAVIS_OS_NAME}
url=https://${GH_TOKEN}@github.com/Programfan/atom-config.git
git clone ${url} -b $branch atom-packages
echo "  Preparing package files ..."
rm -rf atom-packages/*
cp -rf ${HOME}/.atom/packages/* atom-packages
echo "$(date +%Y-%m-%d@%H:%M:%S)" > atom-packages/VERSION
cd atom-packages
echo "  Applying patches ..."
for p in $(find ../patches -name '[0-9]*.patch'); do
  patch -p1 < $p
done
git config user.email "zyangmath@gmail.com"
git config user.name "Yang Zhang"
echo "  Adding files to local git repository ..."
git add -A . &>/dev/null
git commit -m "Update packages $(date +%Y-%m-%d@%H:%M:%S)" &>/dev/null
echo "  Pushing to remote repository ..."
git push origin $branch:$branch &>/dev/null
echo "Done."

exit
