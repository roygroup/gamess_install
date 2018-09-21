# General Atomic and Molecular Electronic Structure System (GAMESS) install script
This is a self contained bash script that attempts to automate the process of installing the GAMESS package on the roygroup cluster.

To install
----------
Change the path to the source file for GAMESS ( on line 8 )
```
SRC_FILE="./gamess_2018_R2.tar.gz"
```
and the build directory ( on line 9 )
```
BUILD_DIR=/home/ngraymon/.dev/ubuntu_18.04/gamess
```
then run the script:
```
./gamess_install.sh
```

The expect_config_script handles the configuration of gamess
