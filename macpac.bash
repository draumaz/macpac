#!/usr/bin/env bash -e

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

BASENAME=$(
  echo ${2} | \
    tr '/' '\n' | \
    tail -1 | \
    sed 's/.macpacz//g' | \
    sed 's/-.*//g'
)

case ${REPO_PATH} in "")
REPO_PATH="" # point to a directory containing .pkgz files
;; esac

PKG_PATH=$(
  find ${REPO_PATH} \
    -name '*.pkgz' \
    -and -name "*$BASENAME*" \
    | tail -1
)

uninstall() {
  for i in `tar -tf ${PKG_PATH}`; do
    case ${i} in
      *local/|*locale/|*bin/|*include/|*lib/|*info/|*doc/|*opt/|*share/|*man/) ;;
      *) rm -rfv /${i} ;;
    esac
  done
}

install() {
  printf "installing ${BASENAME}... "
  tar -xpf ${PKG_PATH} \
    --strip-components=1 \
    -C /opt
  echo "done."
}

case "${1}" in
  i|install)   install   "${@}" ;; 
  u|uninstall) uninstall "${@}" ;;
  *)           xelp             ;;
esac
