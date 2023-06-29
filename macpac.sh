#!/usr/bin/env bash -e

# macpac | draumaz (2023)

case ${MACPAC_VERBOSITY} in yes|1) VERB=-v ;; esac

case ${MACPAC_REPO} in '')
  MACPAC_REPO="https://macpac.draumaz.xyz/m2/bin/index.html" ;;
esac

case ${MACPAC_INSTALL_PATH} in '')
  MACPAC_INSTALL_PATH="/opt/local" ;;
esac

NULL=""; SUCCESS="✅ "; LOADING="🔁"

TAILGRAB() { echo ${1} | tr ${2} '\n' | tail -${3}; }
NLIST() { curl -sL ${MACPAC_REPO} | tr '>' '\n' | \
  tr '"' '\n' | grep https | tr '/' '\n' | grep pkgz | sed 's/.pkgz//' | sort; }

INHELP() {
  cat << EOF
macpac is a tiny network package installer for macOS.

$ macpac i|install    [pkg]
$ macpac u|uninstall  [pkg]
$ macpac h|help
$ macpac l|list
EOF
exit 1
}

pkg_get() {
  NETPKG=$(curl -sL ${MACPAC_REPO} | tr '>' '\n' | tr '"' '\n' | \
    grep https | grep ${PKG_NAME}) || true
  find /tmp/ -maxdepth 1 -name '*.pkgz' -delete; cd /tmp
  printf "*DOWNLOAD* | $(TAILGRAB ${NETPKG} / 1) ${LOADING}"
  curl -sfLO ${NETPKG}; printf "${SUCCESS}\n"
  TARGET_PKG=$(TAILGRAB ${NETPKG} / 1); TARGET_PKG_NAME=${TARGET_PKG}
}

uninstall() {
  pkg_get ${PKG_NAME}
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
  pkg_get ${PKG_NAME}
  printf "*INSTALL * | ${TARGET_PKG} ${LOADING}"
  bsdtar -xp ${VERB} -f ${TARGET_PKG} --strip-components=2 -C ${MACPAC_INSTALL_PATH}
  printf "${SUCCESS}\n"
}

case "${1}" in
  i|install)     ACTIVE=install   ;;
  u|uninstall)   ACTIVE=uninstall ;;
  l|list)   NLIST    ;;
  h|help|*) NHELP    ;;
esac

case "${3}" in
  '') PKG_NAME="$2"; $ACTIVE ${PKG} ;;
  *) shift; for PKG in ${@}; do PKG_NAME=${PKG}; ${ACTIVE} ${PKG}; done ;;
esac
