#!/bin/bash

# see /gamess/machines/readme.unix for additional information

# ------------------------------------------------------------------------------------------------------------
# path & file name variables - change these two as needed
# ------------------------------------------------------------------------------------------------------------
SRC_FILE="./gamess_2018_R2.tar.gz"
BUILD_DIR=/home/ngraymon/.dev/ubuntu_18.04/gamess
# ------------------------------------------------------------------------------------------------------------
if [ ! -f $SRC_FILE ]; then
    echo "src file $SRC_FILE could not be found";
    exit 0;
fi
mkdir -p $BUILD_DIR
# ------------------------------------------------------------------------------------------------------------
# Step 1 & 2 (unzip to target directory)
# ------------------------------------------------------------------------------------------------------------
# --skip-old-files speeds up the script if it needs to be re-run - assuming the files do not need to overwritten
tar xzf $SRC_FILE -C $BUILD_DIR --strip-components=1 --skip-old-files
# ------------------------------------------------------------------------------------------------------------
# Step 3 (not needed right now)
# ------------------------------------------------------------------------------------------------------------
# Consider changing the a few scripts to use tcsh instead which *might* be better on Ubuntu than the default shell
# Not necessary at the moment for now
# ------------------------------------------------------------------------------------------------------------
# Step 4 (run the config script)
# ------------------------------------------------------------------------------------------------------------
export PAGER=cat
# first arg is the directory which expect will cd to and execute the install.sh script whithin
module load intel-mkl/2018.3.222  # this adds the MKLROOT environment variable
./expect_config_script.sh $BUILD_DIR $MKLROOT
echo "Finished Step 4 - running the config script"
# ------------------------------------------------------------------------------------------------------------
# Step 5 (compile the computer science support for parallel GAMESS, known as the Distributed Data Interface (DDI).)
# ------------------------------------------------------------------------------------------------------------
cd $BUILD_DIR/ddi
./compddi >& compddi.log &
wait
mv ddikick.x ..
echo "Finished Step 5 - compiling the DDI"
# ------------------------------------------------------------------------------------------------------------
# Step 6 ( Compile all of the GAMESS source code )
# ------------------------------------------------------------------------------------------------------------
cd $BUILD_DIR
./compall >& compall.log &
wait
echo "Finished Step 6 - compiling the GAMESS source code"
# # ------------------------------------------------------------------------------------------------------------
# # Step 7 ( Link an executable form of GAMESS )
# # ------------------------------------------------------------------------------------------------------------
cd $BUILD_DIR
./lked gamess 01 >& lked.log &
wait
echo "Finished Step 7 - linking the GAMESS executable"
# ------------------------------------------------------------------------------------------------------------
# Step 8 ( Edit 'rungms' and 'runall' so the default version number is not 00, but rather what you what you used in Step 7. )
# ------------------------------------------------------------------------------------------------------------
cd $BUILD_DIR
# change rungms
TARGET="set SCR=/scr/\$USER"
REPLACEMENT="set SCR=/scratch/\$USER"
sed -i "s|$TARGET|$REPLACEMENT|" "$BUILD_DIR/rungms"
# -----------------------------------------------------------
TARGET="set USERSCR=/u1/\$USER/scr"
REPLACEMENT="set USERSCR=/home/\$USER/\.gamess_ascii_files"
sed -i "s|$TARGET|$REPLACEMENT|" "$BUILD_DIR/rungms"
# -----------------------------------------------------------
TARGET="set GMSPATH=/u1/mike/gamess"
REPLACEMENT="set GMSPATH=$BUILD_DIR"
sed -i "s|$TARGET|$REPLACEMENT|" "$BUILD_DIR/rungms"
# -----------------------------------------------------------
TARGET="if (null\$VERNO == null) set VERNO=00"
REPLACEMENT="if (null\$VERNO == null) set VERNO=01"
sed -i "s|$TARGET|$REPLACEMENT|" "$BUILD_DIR/rungms"
# -----------------------------------------------------------

# IMPORTANT!! each user needs to create the associated directory $USERSCR (just remind them yourself)
echo "Finished Step 8 - editing the rungms and runall"
# ------------------------------------------------------------------------------------------------------------
# Step 9 ( Test the program by running all of the short tests. )
# ------------------------------------------------------------------------------------------------------------
cd $BUILD_DIR
# -- server --
srun --pty ./runall 01
# -- locally --
# ./runall 01 >& runall.log &
# wait

./tests/standard/checktst
echo "Finished Step 9 - Testing GAMESS"

# reference example located at
# https://www.webmo.net/support/gamess_linux.html
