# [this project has been retired as I no longer use Apple products.](#)


# macpac(1) - a tiny HTTPS-based package installer for macOS, written in (near)-POSIX shell.

Version 0.2, July 2023

```
macpac [COMMAND] [PACKAGE]
```

<a name="environment-variables"></a>

# Environment Variables


* **MACPAC_INSTALL_PATH**  
  a directory exported to $PATH that macpac can install to.
  
  **EXAMPLE:** export MACPAC_INSTALL_PATH="/usr/local"
* **MACPAC_REPO**  
  an http(s) link to a list of package .tar.gz files.
  
  **EXAMPLE:** export MACPAC_REPO="https://repo.mysite.com/repo.html"

<a name="commands"></a>

# Commands


* **--install**  
  search ${MACPAC_REPO} or ${PWD} for a package and install it.
* **--uninstall**  
  search ${MACPAC_REPO} or ${PWD} for a package and uninstall it.
* **--examine**  
  search ${MACPAC_REPO} or ${PWD} for a package and show its insides.
* **--bins **  
  display all installed binaries in ${MACPAC_INSTALL_PATH}.
* **--help **  
  show a quick help screen.
* **--list **  
  pull ${MACPAC_REPO} and parse all package titles.
* **--selfup**  
  update your macpac 'binary' directly from master.
* **--stats**  
  show helpful information regarding your macpac install.
  

<a name="author"></a>

# Author

Written by draumaz.
