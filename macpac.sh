#!/bin/sh -e

case ${REPO_PATH} in "")
REPO_PATH="" # point to a directory containing .pkgz files
;; esac

xelp() {
  cat << EOF
macpac is a tiny package helper for macOS.

$ macpac install   [pkg]
$ macpac uninstall [pkg]
$ macpac help
EOF
exit 1
}

case "" in $1|$2) xelp ;; esac

BASENAME() {
  echo ${PKG_NAME} | \
    tr '/' '\n' | sed 's/-.*//g' | tail -1
}

PKG_PATH() {
  find ${REPO_PATH} \
    -name '*.pkgz' \
    -and -name "*`BASENAME`*" | tail -1
}

uninstall() {
  printf "uninstalling `BASENAME`... "
  for i in `tar -tf $(PKG_PATH)`; do
    case ${i} in
      *local/|*locale/|*bin/|*include/|*lib/|*info/|*doc/|*opt/|*share/|*man/) ;;
      *) rm -rf /${i} ;;
    esac
  done
  echo "done."
}

install() {
  printf "installing `BASENAME`... "
  tar -xpf `PKG_PATH` \
    --strip-components=1 \
    -C /opt
  echo "done."
}

case "${1}" in
  i|install)   ACTIVE=install   ;; 
  u|uninstall) ACTIVE=uninstall ;;
  h|help|*)           xelp             ;;
esac

case "${3}" in
  "") PKG_NAME="$2"; $ACTIVE ${PKG} ;;
  *) shift; for PKG in ${@}; do PKG_NAME=${PKG}; ${ACTIVE} ${PKG}; done ;;
esac