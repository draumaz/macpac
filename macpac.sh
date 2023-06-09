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
[netinstall]
macpac is a tiny package helper for macOS.

$ macpac install    [pkg]
$ macpac netinstall [pkg]
$ macpac uninstall  [pkg]
$ macpac help
$ macpac list
$ macpac netlist
$ macpac wrap
EOF
exit 1
}

# return basic name for display
BASENAME() {
  echo ${PKG_NAME} | \
    tr '/' '\n' | sed 's/@.*//g' | tail -1
}

# return direct path to BASENAME's .pkgz
PKG_PATH() {
  find ${MACPAC_PKGS_PATH} \
    -name '*.pkgz' \
    -and -name "*${PKG_NAME}*" | tail -1
}

wrap() {
  printf "wrapping ${2}.pkgz... "
  tar -cz ${VERB} -f ${MACPAC_PKGS_PATH}/${2}.pkgz *
  printf "done."
  exit 0
}

uninstall() {
  printf "uninstalling `BASENAME`... "
  for i in `bsdtar -tf $(PKG_PATH)`; do
    case ${i} in
      # blacklisted prefixes (not skipping them causes bad things)
      *etc/|*local/|*locale/|*bin/|*include/|*lib/|*info/|*doc/|*opt/|*share/|*man/) ;;
      *) rm -rf ${VERB} /${i} ;;
    esac
  done
  echo "done."
}

netlist() {
  curl -sL https://macpac.draumaz.xyz/m2/index.html | \
    tr '>' '\n' | tr '"' '\n' | grep https | tr '/' '\n' | grep pkgz | sed 's/.pkgz//g'
}

netinstall() {
  find /tmp/ -maxdepth 1 -name "*.pkgz" -delete
  cd /tmp
  printf "locating ${PKG_NAME}... "
  NETPKG=$(curl -sL https://macpac.draumaz.xyz/m2/index.html | \
    tr '>' '\n' | tr '"' '\n' | grep https | grep ${PKG_NAME}) || true
  case $NETPKG in "") printf "not found.\n"; exit 1 ;; esac
  curl -fLO ${NETPKG}
  printf "installing ${PKG_NAME}... "
  bsdtar -xp ${VERB} -f $(find . -maxdepth 1 -name "*.pkgz") \
    --strip-components=2 \
    -C ${MACPAC_INSTALL_PATH}
  find /tmp/ -maxdepth 1 -name "*.pkgz" -delete
  echo "done."
}

install() {
  printf "installing `PKG_PATH|tr '/' '\n'|tail -1`... "
  bsdtar -xp ${VERB} -f `PKG_PATH` \
    --strip-components=2 \
    -C ${MACPAC_INSTALL_PATH}
  echo "done."
}

case "${1}" in
  i|install)    ACTIVE=install    ;;
  n|netinstall) ACTIVE=netinstall ;;
  nl|netlist)    ACTIVE=netlist ;;
  u|uninstall)  ACTIVE=uninstall  ;;
  l|list)   xist      ;;
  w|wrap)   wrap ${@} ;;
  h|help|*) xelp      ;;
esac

case "${3}" in
  "") PKG_NAME="$2"; $ACTIVE ${PKG} ;;
  *) shift; for PKG in ${@}; do PKG_NAME=${PKG}; ${ACTIVE} ${PKG}; done ;;
esac
