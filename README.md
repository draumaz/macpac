# macpac
- A barebones macOS package manager where you gotta make the packages yourself.
- Think of it like Linux From Scratch but infinitely less educational c:

# environment variables
```
${MACPAC_PKGS_PATH} ~ a folder containing .pkgz files, a tarball with a packages file tree.
${MACPAC_PKGS_PATH} ~ the path that you want macpac to install things.
${MACPAC_VERBOSITY} ~ set to 'yes' for long, messy tar output!
```
- these can be pre-exported in a .profile.

# usage
```
[~] % macpac install tmux
installing tmux... done.
[~] % macpac uninstall tmux
uninstalling tmux... done.
[~] %
```

# usage tips
- .pkgz files, the heart of macpac, are literally just tarballs with a binary file tree in them.
```
[~/packages] % tar -tf tree-2.1.1.pkgz
opt/
opt/local/
opt/local/bin/
opt/local/share/
opt/local/share/man/
opt/local/share/man/man1/
opt/local/share/man/man1/tree.1
opt/local/bin/tree
[~/packages] %
```
- if you've ever packaged for Slackware or CRUX, you'll be right at home.

# compiling tips

- fakeroot into $PWD/dest while compiling, then tarball into a .pkgz file.
```
$ make install DESTDIR=$PWD/dest
$ cd dest
$ macpac wrap ${PACKAGE_NAME}
```

- macOS gets cagey with libraries, so here are some variables it might be helpful to set.

```
LDFLAGS="-L${MACPAC_PKGS_PATH}/lib
CPPFLAGS="-I${MACPAC_PKGS_PATH}/include
DYLD_FALLBACK_LIBRARY_PATH="${MACPAC_PKGS_PATH}/lib"
```
