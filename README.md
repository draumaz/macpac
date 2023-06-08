# macpac
A barebones macOS package manager where you gotta make the packages yourself

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

# compiling tips

- fakeroot into $PWD/dest while compiling, then tarball into a .pkgz file.
```
$ make install DESTDIR=$PWD/dest > /dev/null 2>&1
$ cd dest
$ tar -cvzf ~/packages/package-2.1.0.pkgz *
```

- macOS gets cagey with libraries, so here are some variables it might be helpful to set.

```
LDFLAGS="-L${MACPAC_PKGS_PATH}/lib
CPPFLAGS="-I${MACPAC_PKGS_PATH}/include
DYLD_FALLBACK_LIBRARY_PATH="${MACPAC_PKGS_PATH}/lib"
```
