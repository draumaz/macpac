#!/bin/sh -e

case ${MACPAC_VERBOSITY} in yes|1) VERB=-v ;; esac

test -z ${MACPAC_INSTALL_PATH} && MACPAC_INSTALL_PATH="/opt/local"
test -z ${MACPAC_REPO} && MACPAC_REPO="https://macpac.draumaz.xyz/repos/opt-out-of-air/bin/index.html"

MACPAC_VERSION="v0.1"
SUCCESS="✅ "; FAILURE="🆘 "; LOADING="🔁"

TOUCHY()   { touch ${1} > /dev/null 2>&1 || { printf "${FAILURE}${2}\n"; }; }
TMP_WIPE() { find /tmp/ -maxdepth 1 -name '*.tar.gz' -delete; }
TAILGRAB() { echo ${1} | tr ${2} '\n' | tail -${3}; }
VERSION()  { printf "macpac, ${MACPAC_VERSION}\n"; exit 0; }
EXAMINE()  { PKG_GET ${PKG_NAME}; bsdtar -tf ${TARGET_PKG}; TMP_WIPE; exit 0; }

NLIST() { curl -sL ${MACPAC_REPO} | tr '>' '\n' | \
  tr '"' '\n' | grep https | tr '/' '\n' | grep tar.gz | sed 's/.tar.gz//' | sort; }

INHELP() {
  cat << EOF
macpac, by draumaz (2023) [${MACPAC_VERSION}]

stats
--------
* MACPAC_INSTALL_PATH | ${MACPAC_INSTALL_PATH} `TOUCHY ${MACPAC_INSTALL_PATH} "[no r/w]"`
* MACPAC_REPO         | ${MACPAC_REPO}
* execute path        | ${0}
* installation size   | `du -sh ${MACPAC_INSTALL_PATH} | awk '{print $1}'`

commands
--------
* macpac install   [PKG]
* macpac uninstall [PKG]
* macpac examine   [PKG]
* macpac list
* macpac help
EOF
exit 1
}

PKG_GET() {
  NETPKG=$(curl -sL ${MACPAC_REPO} | tr '>' '\n' | tr '"' '\n' | \
    grep https | grep ${PKG_NAME}) || true
  TMP_WIPE; cd /tmp
  printf "*DOWNLOAD* | $(TAILGRAB ${NETPKG} / 1) ${LOADING}"
  curl -sfLO ${NETPKG}; printf "${SUCCESS}\n"
  TARGET_PKG=$(TAILGRAB ${NETPKG} / 1); TARGET_PKG_NAME=${TARGET_PKG}
}

UNINSTALL() {
  PKG_GET ${PKG_NAME}
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

INSTALL() {
  PKG_GET ${PKG_NAME}
  printf "*INSTALL * | ${TARGET_PKG} ${LOADING}"
  bsdtar -xp ${VERB} -f ${TARGET_PKG} --strip-components=2 -C ${MACPAC_INSTALL_PATH}
  printf "${SUCCESS}\n"
}

case "${1}" in
  i|install|-i|--install)       ACTIVE=INSTALL   ;;
  u|uninstall|-u|--uninstall)   ACTIVE=UNINSTALL ;;
  e|examine|-e|--examine)       ACTIVE=EXAMINE   ;;
  l|list|-l|--list)             ACTIVE=NLIST     ;;
  v|version|-v|--version)       ACTIVE=VERSION   ;;
  h|help|-h|--help|*)           ACTIVE=INHELP    ;;
esac

case "${3}" in
  '') PKG_NAME="$2"; $ACTIVE ${PKG} ;;
  *) shift; for PKG in ${@}; do PKG_NAME=${PKG}; ${ACTIVE} ${PKG}; done ;;
esac
