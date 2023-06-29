# macpac
- a tiny network package installer for macOS.
- supply a link to some tarballs, and macpac will handle the rest.

# preparation

- decide on a good install path. i like /opt/local, but you can literally set anything.
```
export MACPAC_INSTALL_PATH="/usr/opt/src/lib/man/man46/opt/bin/local"
sudo mkdir -pv ${MACPAC_INSTALL_PATH}
sudo chown -Rv {your_username} ${MACPAC_INSTALL_PATH}
```

# usage
- installing couldn't be easier.
```
$ macpac install autoconf
*DOWNLOAD* | autoconf@2.71.pkgz 🔁✅
*INSTALL * | autoconf@2.71.pkgz 🔁✅
```

- ...and to verify install:
```
$ find ${MACPAC_INSTALL_PATH} -name '*autoconf*'
/opt/local/bin/autoconf
/opt/local/share/man/man1/autoconf.1
/opt/local/share/info/autoconf.info
...
```

# my macpac repository
- i maintain a hearty collection of M2-built Unix tools. feel free to use them!
```
$ export MACPAC_REPO="https://macpac.draumaz.xyz/m2/bin/index.html"
$ macpac list
autoconf@2.71
automake@1.16.5
cmake@3.27.0-rc2
...
```
