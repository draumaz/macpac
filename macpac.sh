#!/bin/sh -e

# fallback variables if not found in env
test -z ${MACPAC_INSTALL_PATH} && MACPAC_INSTALL_PATH="/opt/local"

MACPAC_VERSION=`case ${PWD} in *macpac*) git rev-parse HEAD | cut -c34- ;; *) echo 0.2.4 ;; esac`
MACPAC_HEADER="macpac, by draumaz (2023) [${MACPAC_VERSION}]"

SUCCESS="✅ "; FAILURE="🆘 "; LOADING="🔁"

BINS()     { find ${MACPAC_INSTALL_PATH}/bin -type f | sed "s|${MACPAC_INSTALL_PATH}/bin/||g"; }
EXAMINE()  { GOODPKG; bsdtar -tvf ${TARGET_PKG} | less; TMP_WIPE; }
IS_VERB()  { case "${MACPAC_VERBOSITY}" in yes|1) true ;; *) false ;; esac; }
MANPAGE()  { man macpac; }
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

RECEIVE() {
  NETPKG=`curl -sL ${MACPAC_REPO} | tr '>' '\n' | tr '"' '\n' | \
    grep https | grep ${PKG_NAME}` || true
  TMP_WIPE; cd /tmp
  printf "[download] "
  curl -sfLO ${NETPKG} > /dev/null 2>&1 || return 1
  TARGET_PKG=`TAILGRAB ${NETPKG} / 1`; TARGET_PKG_NAME=${TARGET_PKG}
}

GOODPKG() {
  if test ! -e "${PKG_NAME}"; then
    if ! RECEIVE "${PKG_NAME}"; then
      printf "\n${PKG_NAME} does not appear to be a valid package.\n"; exit 1
    fi
  else TARGET_PKG="${PKG_NAME}"; fi
}

INSTALL() {
  printf "(${PKG_NAME}) "; GOODPKG; printf "[install]"
  bsdtar -xp ${VERB} -f ${TARGET_PKG} --strip-components=2 -C ${MACPAC_INSTALL_PATH}
  printf " ${SUCCESS}\n"
}

LIST() {
  curl -sL ${MACPAC_REPO} | \
    grep 'https' | tr '"' '\n' | grep 'https' | \
    tr '/' '\n' | grep 'tar.gz' | sed 's/.tar.gz//' | grep "${PKG_NAME}"
}

SELFUP() {
  SLP="${MACPAC_INSTALL_PATH}"
  mkdir -p "${SLP}/bin ${SLP}/share/man/man1"
  ls -al ${SLP}/bin/macpac || true
  ls -al ${SLP}/share/man/man1/macpac.1 || true
  curl -sL https://github.com/draumaz/macpac/archive/refs/heads/main.tar.gz | \
    tar -xpzf - \
      --strip-components=1 \
      -C ${SLP} \
      macpac-main/macpac.sh \
      macpac-main/macpac.1
  mv ${SLP}/macpac.sh ${SLP}/bin/macpac
  mv ${SLP}/macpac.1 ${SLP}/share/man/man1/macpac.1
  printf "\n"
  ls -al ${SLP}/bin/macpac || true
  ls -al ${SLP}/share/man/man1/macpac.1 || true
}

STATS() {
  cat << EOF
${MACPAC_HEADER}

stats
--------

* installing to:      | ${MACPAC_INSTALL_PATH} `TOUCHY ${MACPAC_INSTALL_PATH} " [no r/w]"`
* installation size   | `du -sh ${MACPAC_INSTALL_PATH} | awk '{print $1}'`
* installed binaries  | `ls -1 ${MACPAC_INSTALL_PATH}/bin | wc -l | awk '{print $1}'`
* execute path        | ${0}
* active repo         | ${MACPAC_REPO}
EOF
}

REMOVE() {
  GOODPKG "${PKG_NAME}"
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
