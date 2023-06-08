#!/bin/sh -e

# macpac | draumaz (2023)

PKG_PREFIX="/opt/local" # customizable! just make sure you have r+w

case ${REPO_PATH} in "")
REPO_PATH="" # point to a directory containing .pkgz files
;; esac

xist() {
  find ${REPO_PATH} -name "*.pkgz" | \
    tr '/' '\n' | \
    grep ".pkgz" | sed 's/.pkgz//g'
}

xelp() {
  cat << EOF
macpac is a tiny package helper for macOS.

$ macpac install   [pkg]
$ macpac uninstall [pkg]
$ macpac help
$ macpac list
EOF
exit 1
}

# return basic name for display
BASENAME() {
  echo ${PKG_NAME} | \
    tr '/' '\n' | sed 's/-.*//g' | tail -1
}

# return direct path to BASENAME's .pkgz
PKG_PATH() {
  find ${REPO_PATH} \
    -name '*.pkgz' \
    -and -name "*`BASENAME`*" | tail -1
}

uninstall() {
  printf "uninstalling `BASENAME`... "
  for i in `bsdtar -tf $(PKG_PATH)`; do
    case ${i} in
      # blacklisted prefixes (not skipping them causes bad things)
      *local/|*locale/|*bin/|*include/|*lib/|*info/|*doc/|*opt/|*share/|*man/) ;;
      *) rm -rf /${i} ;;
    esac
  done
  echo "done."
}

install() {
  printf "installing `BASENAME`... "
  bsdtar -xpf `PKG_PATH` \
    --strip-components=2 \
    -C ${PKG_PREFIX}
  echo "done."
}

case "${1}" in
  i|install)   ACTIVE=install   ;; 
  u|uninstall) ACTIVE=uninstall ;;
  l|list) xist ;; h|help|*) xelp ;;
esac

case "${3}" in
  "") PKG_NAME="$2"; $ACTIVE ${PKG} ;;
  *) shift; for PKG in ${@}; do PKG_NAME=${PKG}; ${ACTIVE} ${PKG}; done ;;
esac
