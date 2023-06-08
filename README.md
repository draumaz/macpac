# macpac
A barebones macOS package manager where you gotta make the packages yourself

# environment variables
```
$REPO_PATH ~ a folder containing .pkgz files, a tarball with a packages file tree
$PKG_PREFIX ~ the path that you want macpac to install things
```

# compiling tips

- fakeroot into $PWD/dest while compiling, then tarball into a .pkgz file.
```
$ make install DESTDIR=$PWD/dest > /dev/null 2>&1
$ cd dest
$ tar -cvzf ~/packages/package-2.1.0.pkgz *
```

- macOS gets cagey with libraries, so here are some variables it might be helpful to set.

```LDFLAGS="-L${PKG_PREFIX}/lib```

```CPPFLAGS="-I${PKG_PREFIX}/include```

```DYLD_FALLBACK_LIBRARY_PATH="${PKG_PREFIX}/lib"```
