#!/bin/sh -e

# macpac | draumaz (2023)

## begin config ##
case ${MACPAC_PKGS_PATH} in "")
MACPAC_PKGS_PATH="" # point to a directory containing .pkgz files.
;; esac

case ${MACPAC_INSTALL_PATH} in "")
MACPAC_INSTALL_PATH="" # make sure you have r+w access!
;; esac
## end   config ##

case ${MACPAC_VERBOSITY} in yes|1) VERB="-v" ;; esac

xist() {
  find ${MACPAC_PKGS_PATH} -name "*.pkgz" | \
    tr '/' '\n' | \
    grep ".pkgz" | sed 's/.pkgz//g'
  exit 0
}

xelp() {
  cat << EOF
macpac is a tiny package helper for macOS.

$ macpac install   [pkg]
$ macpac uninstall [pkg]
$ macpac help
$ macpac list
$ macpac wrap
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
  find ${MACPAC_PKGS_PATH} \
    -name '*.pkgz' \
    -and -name "*`BASENAME`*" | tail -1
}

wrap() {
  printf "wrapping ${2}.pkgz... "
  tar -cz ${VERB} -f ${MACPAC_PKGS_PATH}/${1}.pkgz *
  printf "done."
  exit 0
}

uninstall() {
  printf "uninstalling `BASENAME`... "
  for i in `bsdtar -tf $(PKG_PATH)`; do
    case ${i} in
      # blacklisted prefixes (not skipping them causes bad things)
      *local/|*locale/|*bin/|*include/|*lib/|*info/|*doc/|*opt/|*share/|*man/) ;;
      *) rm -rf ${VERB} /${i} ;;
    esac
  done
  echo "done."
}

install() {
  printf "installing `BASENAME`... "
  bsdtar -xp ${VERB} -f `PKG_PATH` \
    --strip-components=2 \
    -C ${MACPAC_INSTALL_PATH}
  echo "done."
}

case "${1}" in
  i|install)   ACTIVE=install   ;; 
  u|uninstall) ACTIVE=uninstall ;;
  l|list) xist ;; w|wrap) wrap ${@} ;; h|help|*) xelp ;;
esac

case "${3}" in
  "") PKG_NAME="$2"; $ACTIVE ${PKG} ;;
  *) shift; for PKG in ${@}; do PKG_NAME=${PKG}; ${ACTIVE} ${PKG}; done ;;
esac
