#!/bin/sh -e

# fallback variables if none are found in env
test -z ${MACPAC_INSTALL_PATH} && MACPAC_INSTALL_PATH="/opt/local"

MACPAC_VERSION="v0.1"; MACPAC_HEADER="macpac, by draumaz (2023) [${MACPAC_VERSION}]"
SUCCESS="✅ "; FAILURE="🆘 "; LOADING="🔁"

BINS()     { find ${MACPAC_INSTALL_PATH}/bin -type f | sed "s|${MACPAC_INSTALL_PATH}/bin/||g"; }
EXAMINE()  { RECEIVE ${PKG_NAME}; bsdtar -tf ${TARGET_PKG} | less; TMP_WIPE; }
TAILGRAB() { echo ${1} | tr ${2} '\n' | tail -${3}; }
TMP_WIPE() { find /tmp/ -maxdepth 1 -name '*.tar.gz' -delete; }
TOUCHY()   { touch ${1} > /dev/null 2>&1 || { printf "${FAILURE}${2}\n"; }; }
VERSION()  { printf "macpac, ${MACPAC_VERSION}\n"; exit 0; }

DEFHELP() {
  cat << EOF
${MACPAC_HEADER}

commands
--------
* macpac --install   [PKG]
* macpac --uninstall [PKG]
* macpac --examine   [PKG]
* macpac --bins
* macpac --help
* macpac --list
* macpac --selfup
* macpac --stats
EOF
exit 1
}

INSTALL() {
  if test ! -e "${PKG_NAME}"; then RECEIVE "${PKG_NAME}"; else TARGET_PKG="${PKG_NAME}"; fi
  printf "*INSTALL * | ${TARGET_PKG} ${LOADING}"
  bsdtar -xp ${VERB} -f ${TARGET_PKG} --strip-components=2 -C ${MACPAC_INSTALL_PATH}
  printf "${SUCCESS}\n"
}

LIST() {
  curl -sL ${MACPAC_REPO} | \
    grep 'https' | tr '"' '\n' | grep 'https' | \
    tr '/' '\n' | grep 'tar.gz' | sed 's/.tar.gz//' | grep "${PKG_NAME}"
}

RECEIVE() {
  NETPKG=`curl -sL ${MACPAC_REPO} | tr '>' '\n' | tr '"' '\n' | \
    grep https | grep ${PKG_NAME}` || true
  TMP_WIPE; cd /tmp
  printf "*DOWNLOAD* | `TAILGRAB ${NETPKG} / 1` ${LOADING}"
  curl -sfLO ${NETPKG}; printf "${SUCCESS}\n"
  TARGET_PKG=`TAILGRAB ${NETPKG} / 1`; TARGET_PKG_NAME=${TARGET_PKG}
}

SELFUP() {
  SLP="${MACPAC_INSTALL_PATH}/bin"
  mkdir -p "${SLP}"
  ls -al ${SLP}/macpac || true
  curl -sL https://github.com/draumaz/macpac/archive/refs/heads/main.tar.gz | \
    tar -xpzf - \
      --strip-components=1 \
      -C ${SLP} \
      macpac-main/macpac.sh
  mv ${SLP}/macpac.sh ${SLP}/macpac
  ls -al ${SLP}/macpac
}

STATS() {
  cat << EOF
${MACPAC_HEADER}

stats
--------

* installing to:      | ${MACPAC_INSTALL_PATH} `TOUCHY ${MACPAC_INSTALL_PATH} " [no r/w]"`
* installation size   | `du -sh ${MACPAC_INSTALL_PATH} | awk '{print $1}'`
* execute path        | ${0}
* active repo         | ${MACPAC_REPO}
EOF
}

REMOVE() {
  RECEIVE ${PKG_NAME}
  printf "*REMOVE*   | ${TARGET_PKG} ${LOADING}"
  for i in `bsdtar -tf ${TARGET_PKG}`; do
    case ${i} in
      # blacklisted paths (not skipping them causes bad things)
      *etc/|*local/|*locale/|*bin/|*include/|*lib/|*info/|*doc/|*opt/|*share/|*man*/) ;;
      *) rm -rf ${VERB} /${i} ;;
    esac
  done
  printf "${SUCCESS}\n"
}

# this little guy likes to mess with syntax highlighting :c
case "${MACPAC_VERBOSITY}" in 1|yes) VERB=-v ;; esac;

case "${1}" in
  install|--install|i|-i|add|--add|a|-a)           ACTIVE=INSTALL   ;;
  uninstall|--uninstall|u|-u|remove|--remove|r|-r) ACTIVE=REMOVE    ;;
  bins|--bins|-b)         ACTIVE=BINS ;;
  examine|--examine|-e)   ACTIVE=EXAMINE ;;
  list|--list|-l|l)       ACTIVE=LIST ;;
  stats|--stats|-s|s)     ACTIVE=STATS ;;
  selfup|su|--selfup|-su) ACTIVE=SELFUP ;;
  version|--version|v|-v) ACTIVE=VERSION ;;
  help|--help|h|-h|*)     ACTIVE=DEFHELP ;;
esac

case "${3}" in
  '') PKG_NAME="$2"; $ACTIVE ${PKG} ;;
  *) shift; for PKG in ${@}; do PKG_NAME=${PKG}; ${ACTIVE} ${PKG}; done ;;
esac
