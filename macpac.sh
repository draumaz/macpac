#!/usr/bin/env bash -e

# macpac | draumaz (2023)

case ${MACPAC_VERBOSITY} in yes|1) VERB=-v ;; esac
MACPAC_INDEX="https://macpac.draumaz.xyz/m2/bin/index.html"
#MACPAC_INDEX="https://macpac.draumaz.xyz/`sysctl -n machdep.cpu.brand_string | awk {'print $2'}`/`sw_vers -productversion`bin/index.html"

SUCCESS="✅ "; LOADING="🔁"

INHELP() {
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

BASENAME() { echo ${PKG_NAME} | tr '/' '\n' | sed 's/@.*//g' | tail -1; }
TAILGRAB() { echo ${1} | tr ${2} '\n' | tail -${3}; }
PKG_PATH() { find ${MACPAC_PKGS_PATH} -name '*.pkgz' -and -name "*${PKG_NAME}*" | tail -1; }
XLIST() { find ${MACPAC_PKGS_PATH} -name '*.pkgz' | tr '/' '\n' | grep '.pkgz' | sed 's/.pkgz//g' | sort; exit 0; }
NLIST() { curl -sL ${MACPAC_INDEX} | tr '>' '\n' | tr '"' '\n' | grep https | tr '/' '\n' | grep pkgz | sed 's/.pkgz//' | sort; }

wrap() { bsdtar -cz ${VERB} -f ${MACPAC_PKGS_PATH}/${2}.pkgz *; printf ${SUCCESS}\n; exit 0; }

pkg_get() {
  find /tmp/ -maxdepth 1 -name '*.pkgz' -delete
  NETPKG=$(curl -sL https://macpac.draumaz.xyz/m2/bin/index.html | \
    tr '>' '\n' | tr '"' '\n' | grep https | grep ${PKG_NAME}) || true
  cd /tmp
  printf "*DOWNLOAD* | $(TAILGRAB ${NETPKG} / 1) ${LOADING}"
  curl -sfLO ${NETPKG}; printf "${SUCCESS}\n"
  TARGET_PKG=$(TAILGRAB ${NETPKG} / 1); TARGET_PKG_NAME=${TARGET_PKG}
}

uninstall() {
  case $MODE in
    local) TARGET_PKG="`PKG_PATH`" ;;
    net) pkg_get $PKG_NAME ;; 
  esac
  printf "!UNINSTALL! | ${TARGET_PKG} ${LOADING}"
  for i in `bsdtar -tf ${TARGET_PKG}`; do
    case ${i} in
      # blacklisted paths (not skipping them causes bad things)
      *etc/|*local/|*locale/|*bin/|*include/|*lib/|*info/|*doc/|*opt/|*share/|*man/) ;;
      *) rm -rf ${VERB} /${i} ;;
    esac
  done
  printf "${SUCCESS}\n"; exit 0
}

install() {
  case $MODE in
    local) TARGET_PKG="`PKG_PATH`" ;;
    net) pkg_get $PKG_NAME ;; 
  esac
  printf "*INSTALL * | ${TARGET_PKG} ${LOADING}"
  bsdtar -xp ${VERB} -f ${TARGET_PKG} --strip-components=2 -C ${MACPAC_INSTALL_PATH}
  printf "${SUCCESS}\n"
}

case "${1}" in
  i|install)     MODE=local; ACTIVE=install   ;;
  n|netinstall)  MODE=net;   ACTIVE=install   ;;
  u|uninstall)   MODE=local; ACTIVE=uninstall ;;
  nu|netuninst)  MODE=net;   ACTIVE=uninstall ;;
  w|wrap)     wrap ${@} ;;
  l|list)     XLIST     ;;
  nl|netlist) NLIST     ;;
  h|help|*)   INHELP    ;;
esac

case "${3}" in
  '') PKG_NAME="$2"; $ACTIVE ${PKG} ;;
  *) shift; for PKG in ${@}; do PKG_NAME=${PKG}; ${ACTIVE} ${PKG}; done ;;
esac
