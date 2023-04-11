#!/usr/bin/env bash -e

case ${2} in "") exit 1 ;; esac

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

PKG_PATH=$(find ${REPO_PATH} -name '*.pkgz' | tail -1)

# non functional
uninstall() {
  PROTECTED="local:locale:bin:include:lib:doc:opt:share:man"
  for i in `tar -tf ${PKG_PATH}`; do
    for j in `echo ${PROTECTED} | tr ':' '\n'`; do
      case "${i}" in *${j}/) echo $i ;; *) ;; esac
    done
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
  i) install   "${@}" ;; 
  u) uninstall "${@}" ;;
esac || "${@}"
