#!/bin/bash

# only proceed script when started not by pull request (PR)
if [ $TRAVIS_PULL_REQUEST == "true" ]; then
    echo "this is PR, exiting"
    exit 0
fi

# enable error reporting to the console
set -e

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

echo "Downloading package dependencies..."
"$APM_SCRIPT_PATH" clean
"$APM_SCRIPT_PATH" install

INSTALL_PACKAGES="${APM_INSTALL_PACKAGES:=none}"

if [ "$INSTALL_PACKAGES" != "none" ]; then
  echo "Installing atom package dependencies..."
  for pack in $INSTALL_PACKAGES ; do
    "$APM_SCRIPT_PATH" install $pack
  done
fi

url=https://${GH_TOKEN}@github.com/Programfan/atom-config.git
git clone ${url} -b release atom-config
rm -rf atom-config/packages
cp -rf ${HOME}/.atom/packages atom-config

cd atom-config
git config user.email "zyangmath@gmail.com"
git config user.name "Yang Zhang"
git add -A .
git commit -a -m "Update packages on $(date +%Y-%m-%d)"
git push origin release:release

exit
