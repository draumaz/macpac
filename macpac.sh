#!/bin/sh -e

# macpac | draumaz (2023)

## begin config ##
case ${MACPAC_PKGS_PATH} in '')
MACPAC_PKGS_PATH="" # point to a directory containing .pkgz files.
;; esac

case ${MACPAC_INSTALL_PATH} in '')
MACPAC_INSTALL_PATH="" # make sure you have r+w access!
;; esac
## end   config ##

case ${MACPAC_VERBOSITY} in yes|1) VERB=-v ;; esac

xist() {
  find ${MACPAC_PKGS_PATH} -name '*.pkgz' | \
    tr '/' '\n' | \
    grep '.pkgz' | sed 's/.pkgz//g' | sort
  exit 0
}

xelp() {
  cat << EOF
macpac is a tiny package helper for macOS.

$ macpac i|install    [pkg]
$ macpac n|netinstall [pkg]
$ macpac u|uninstall  [pkg]
$ macpac h|help
$ macpac l|list
$ macpac n|netlist
$ macpac w|wrap
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
    -name '*.pkgz' -and -name "*${PKG_NAME}*" | tail -1
}

wrap() {
  for i in 'wrapping' ${2} '...'; do printf $i; printf ' '; done
  bsdtar -cz ${VERB} -f ${MACPAC_PKGS_PATH}/${2}.pkgz *
  printf 'done.'
  exit 0
}

uninstall() {
  printf 'uninstalling `BASENAME`... '
  for i in `bsdtar -tf $(PKG_PATH)`; do
    case ${i} in
      # blacklisted prefixes (not skipping them causes bad things)
      *etc/|*local/|*locale/|*bin/|*include/|*lib/|*info/|*doc/|*opt/|*share/|*man/) ;;
      *) rm -rf ${VERB} /${i} ;;
    esac
  done; echo 'done.'
}

netlist() {
  curl -sL https://macpac.draumaz.xyz/m2/bin/index.html | \
    tr '>' '\n' | tr '"' '\n' | grep https | tr '/' '\n' | grep pkgz | sed 's/.pkgz//g' | sort
}

install() {
  case $MODE in
    local)
      TARGET_PKG="$(PKG_PATH)"
      TARGET_PKG_NAME="$(PKG_PATH | tr '/' '\n' | tail -1)"
    ;;
    net)
      find /tmp/ -maxdepth 1 -name '*.pkgz' -delete
      for i in 'locating' ${PKG_NAME} '...'; do printf $i; printf ' '; done
      NETPKG=$(curl -sL https://macpac.draumaz.xyz/m2/bin/index.html | \
        tr '>' '\n' | tr '"' '\n' | grep https | grep ${PKG_NAME}) || true
      case $NETPKG in
        '') printf 'not found.\n'; exit 1 ;;
        *) for i in 'found!' '~' ${NETPKG}; do printf $i; printf ' '; done
      esac; printf '\n'
      cd /tmp; curl -sfLO ${NETPKG}
      TARGET_PKG="$(echo ${NETPKG} | tr '/' '\n' | tail -1)"
      TARGET_PKG_NAME=${TARGET_PKG}
    ;;
  esac
  for i in 'installing ' ${TARGET_PKG_NAME} '...'; do printf $i; printf ' '; done
  bsdtar -xp ${VERB} -f ${TARGET_PKG} --strip-components=2 -C ${MACPAC_INSTALL_PATH}
  echo 'done.'
}

case "${1}" in
  i|install)     MODE=local; ACTIVE=install ;;
  n|netinstall)  MODE=net;   ACTIVE=install ;;
  nl|netlist)    ACTIVE=netlist    ;;
  u|uninstall)   ACTIVE=uninstall  ;;
  l|list)   xist      ;;
  w|wrap)   wrap ${@} ;;
  h|help|*) xelp      ;;
esac

case "${3}" in
  "") PKG_NAME="$2"; $ACTIVE ${PKG} ;;
  *) shift; for PKG in ${@}; do PKG_NAME=${PKG}; ${ACTIVE} ${PKG}; done ;;
esac
