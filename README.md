# macpac
```
macpac, by draumaz (2023) [v0.1]

stats
--------

* installing to:      | /opt/local
* installation size   | 427M
* execute path        | /opt/local/bin/macpac
* active repo         | https://macpac.draumaz.xyz/repos/opt-out-of-air/bin/index.html
```
- a tiny HTTPS-based package installer for macOS, written in (near)-POSIX shell.

# repository management
- a macpac repository consists of an ```index.html``` with a bunch of a-href'd hyperlinks to tarballs.
```
$ echo ${MACPAC_REPO}
$ https://macpac.draumaz.xyz/repos/opt-out-of-air/bin
$ curl -sL ${MACPAC_REPO} | head -2
<a href="https://macpac.draumaz.xyz/m2/bin/gnupg/gnupg@2.4.2.tar.gz">gnupg/gnupg@2.4.2.tar.gz</a> <br>
<a href="https://macpac.draumaz.xyz/m2/bin/gnupg/libassuan@2.5.5.tar.gz">gnupg/libassuan@2.5.5.tar.gz</a> <br>
```
- these tarballs are Slackware-style file trees that you can directly untar into an install prefix.
```
$ tar -tf libassuan@2.5.5.tar
...
opt/local/share/info/assuan.info
opt/local/lib/pkgconfig/
opt/local/lib/libassuan.la
...
```

# create an install path
- decide on a good install path. i like /opt/local, but you can literally set it to anything.
```
export MACPAC_INSTALL_PATH="/usr/opt/src/lib/man/man46/opt/bin/local" WHO=`whoami`
sudo mkdir -pv ${MACPAC_INSTALL_PATH}
sudo chown -Rv ${WHO} ${MACPAC_INSTALL_PATH}
```

# usage
- retrieving and installing packages couldn't be easier.
```
$ macpac --install autoconf
*DOWNLOAD* | autoconf@2.71.pkgz 🔁✅
*INSTALL * | autoconf@2.71.pkgz 🔁✅
```

- ...verifying install is simple too:
```
$ find ${MACPAC_INSTALL_PATH} -name '*autoconf*'
/opt/local/bin/autoconf
/opt/local/share/man/man1/autoconf.1
/opt/local/share/info/autoconf.info/
...
```

- more commands for your discerning palette:
```
$ macpac --examine which
*DOWNLOAD* | which@2.21.tar.gz 🔁✅
opt/
opt/local/
opt/local/bin/
opt/local/share/
opt/local/share/man/
opt/local/share/info/
opt/local/share/info/which.info
...
```
```
$ macpac --remove vim
*DOWNLOAD* | vim@9.0.1636.tar.gz 🔁✅
*REMOVE*   | vim@9.0.1636.tar.gz 🔁✅
```
```
$ macpac --bins
lzmainfo
chronic
sponge
gpgtar
ccmake
... # it's all your ${MACPAC_INSTALL_PATH}/bin files ;)
```

# repositories

## draumaz/[opt-out-of-air](https://oooa.draumaz.xyz)
- M2 MacBook-Air-exclusively built, general purpose packages. install path is /opt/local.
```
$ MACPAC_REPO="https://macpac.draumaz.xyz/opt-out-of-air/bin" macpac list
autoconf@2.71
automake@1.16.5
cmake@3.27.0-rc2
...
```
