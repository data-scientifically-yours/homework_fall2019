#!/usr/bin/env bash

#-------------------------------------------------------------------------------
# Catch errors
#-------------------------------------------------------------------------------
err() {
  echo "                                                                       "
  echo "======================================================================="
  echo "[$(date +'%Y-%m-%dT%H:%M:%S%z')]                                       "
  echo "$*" >&2
  echo "======================================================================="
  echo "                                                                       "
  exit 1
}

#-------------------------------------------------------------------------------
# wget & unzip
#-------------------------------------------------------------------------------
wgetunzip() {
  TMPFILE=$(mktemp)
  PWD=$(pwd)
  wget "$1" -O $TMPFILE
  unzip -d $PWD $TMPFILE
  rm $TMPFILE
}

#-------------------------------------------------------------------------------
# Yes/No
#-------------------------------------------------------------------------------
yesno() {
  while true; do
    read -p "Would you ?" yn
    case $yn in
      [Yy]*)
        eval ${1}
        break
        ;;
      [Nn]*) exit ;;
      *) echo "Please answer yes or no." ;;
    esac
  done
}

#-------------------------------------------------------------------------------
# Check OS
#-------------------------------------------------------------------------------
checkOS() {
  MUJOCO_VER="mujoco200"
  if [[ "$(uname)" == "Darwin" ]]; then
    MUJOCO_BIN="https://www.roboti.us/download/${MUJOCO_VER}_macos.zip"
    GET_ID=https://www.roboti.us/getid/getid_osx
    
  elif [[ "$(uname)" == "Linux" ]]; then
    MUJOCO_BIN="https://www.roboti.us/download/${MUJOCO_VER}_linux.zip"
    GET_ID=https://www.roboti.us/getid/getid_linux
    sudo apt install unzip
  else
    err 'Detected neither OSX or Linux Operating System'
  fi
}

#-------------------------------------------------------------------------------
# Mujoco
#-------------------------------------------------------------------------------
checkMujoco() {
  MUJOCO_DIR=$HOME/.mujoco
  if [ ! -d "${MUJOCO_DIR}" ]; then
    setupMujoco
  else
    echo "====================================================================="
    echo "$MUJOCO_DIR exists !!                                                "
    echo "Would you like to remove it and create a new one ?!                  "
    echo "====================================================================="
    yesno setupMujoco
  fi
}

setupMujoco() {
  if [ -d "${MUJOCO_DIR}" ]; then rm -rf ${MUJOCO_DIR}; fi
  mkdir -p "${MUJOCO_DIR}"
  keyMujoco
  wgetunzip $MUJOCO_BIN && mv $MUJOCO_VER* "${MUJOCO_DIR}"/$MUJOCO_VER
  echo "======================================================================="
  echo "                   $MUJOCO_VER successfully cloned                     "
  echo "======================================================================="
}

keyMujoco() {
  FILE=$(find . -name 'mjkey.txt' -print -quit)
  if [ -n "$FILE" ]; then
    cp "$FILE" $MUJOCO_DIR
    echo "====================================================================="
    echo "                    mjkey.txt copied successfully                    "
    echo "====================================================================="
  else
    echo "====================================================================="
    echo " mjkey.txt Not found !!                                              "
    echo " Please register for a free trial at                                 "
    echo "                 https://www.roboti.us/license.html                  "
    echo " save it anywhere in your home directory and re-launch the script    "
    echo "====================================================================="
    if [ ! -f getid* ]; then wget $GET_ID; fi
    chmod +x getid* && ./getid*
    exit 1
  fi
}

#-------------------------------------------------------------------------------
# berkley/homework_fall2019
#-------------------------------------------------------------------------------
checkPackage() {
  REPO="homework_fall2019"
  SOURCE="https://github.com/berkeleydeeprlcourse/$REPO.git"
  TARGET="$HOME/berkley/$REPO"
  if [ ! -d "${TARGET}" ]; then
    setupPackage
  else
    echo '$REPO already cloned !!  '
    echo 'Would you like to remove it and clone a new one ?!'
    rm -rf ${TARGET} && yesno setupPackage
  fi
}

setupPackage() {
  mkdir -p "${TARGET}"
  git clone $SOURCE $TARGET && cd $TARGET/hw1 && python setup.py develop
  echo "======================================================================="
  echo "                   $REPO successfully cloned                           "
  echo "======================================================================="
  rm -rf downloads
}

#-------------------------------------------------------------------------------
# Launch
#-------------------------------------------------------------------------------
checkOS \
&& checkMujoco \
&& checkPackage \
&& rm -f $HOME/getid*
echo  'export LD_LIBRARY_PATH=~/.mujoco/mujoco200/bin/' >> ~/.bashrc
source ~/.bashrc
