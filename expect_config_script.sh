#!/usr/bin/expect
# ------------------------------------------------------------------------------------------------------------
# get the input - and set constants
set src_dir [lindex $argv 0];
set intel_mkl_path [lindex $argv 1];
set build_dir $src_dir;
set gamess_version "R2";
set gfortran_version "7.3";
# ------------------------------------------------------------------------------------------------------------
# go to the install directory
cd $src_dir;
# set timeout to 10 seconds
set timeout 10;
# set the output to 'debug' mode so that we can see what the expect script see's
# this can be quite messy as the output from the program and expect can clobber each other
# exp_internal 1

# another way to control output
log_user 0
# log_user 1

send_user "Starting script\n";
# start the config script that we will interact with
spawn "./config";
# ------------------------------------------------------------------------------------------------------------
expect "*After the new window is open, please hit <return> to go on." {
    # This script asks a few questions, depending on your computer system,
    # to set up compiler names, libraries, message passing libraries, and so forth.
    send "\r";  # We assume we already know all the details about our machine
}
expect "*please enter your target machine name:*" {
    # linux64  - Linux (any 64 bit distribution), for x86_64 or ia64 chips, using gfortran, ifort, or perhaps PGI compilers.
    send "linux64\r";
}
expect "*GAMESS directory?*" {
    # Where is the GAMESS software on your system?
    send "$src_dir\r";
}
expect "*GAMESS build directory?*" {
    # Setting up GAMESS compile and link for GMS_TARGET=linux64
    # GAMESS software is located at GMS_PATH=$src_dir
    # Please provide the name of the build locaation.
    # This may be the same location as the GAMESS directory.
    send "$build_dir\r";
}
expect "*Version?*" {
    # Please provide a version number for the GAMESS executable.
    # This will be used as the middle part of the binary's name,
    # for example: gamess.00.x
    send "$gamess_version\r";
}
expect "*Please enter your choice of FORTRAN:*" {
    # Linux offers many choices for FORTRAN compilers, including the GNU
    # compiler suite's free compiler 'gfortran', usually included in
    # any Linux distribution.  If gfortran is not installed, it can be
    # installed from your distribution media.

    # To check on installed GNU compilers, for RedHat/SUSE style Linux,
    #    type 'rpm -aq | grpep gcc' for both languages,
    # and for Debian/Ubuntu style Linux, it takes two commands
    #    type 'dpkg -l | grep gcc'
    #    type 'dpkg -l | grep gfortran'

    # There are also commercial compilers, namely Intel's 'ifort', and
    # Portland Group's 'pgfortran', and Pathscale's 'pathf90'.
    # The last two are not common, and aren't as well tested.

    # type 'which gfortran'  to look for GNU's gfortran   (a good choice),
    # type 'which ifort'     to look for Intel's compiler (a good choice),
    # type 'which pgfortran' to look for Portland Group's compiler,
    # type 'which pathf90'   to look for Pathscale's compiler.
    send "gfortran\r";
}
expect "*version number of your gfortran*" {
    # gfortran is very robust, so this is a wise choice.
    # Please type 'gfortran -dumpversion' or else 'gfortran -v' to
    # detect the version number of your gfortran.
    # This reply should be a string with at least two decimal points,
    # such as 4.1.2 or 4.6.1, or maybe even hyphens like 4.4.2-12.
    # The reply may be labeled as a 'gcc' version,
    # but it is really your gfortran version.

    # Please enter only the first decimal place, such as 4.6 or 4.8:
    send "$gfortran_version\r";
}
expect "*hit <return> to continue to the math library setup.*" {
    send "\r";
}
expect "*Enter your choice of 'mkl' or 'atlas' or 'acml' or 'openblas' or 'pgiblas' or 'none':*" {
    send "mkl\r";
}
expect {
    "*where is your MKL software installed?*" {
        send "$intel_mkl_path\r";
        expect "MKL version (or 'proceed')?*" {
            send "proceed\r";
        }
    }
    timeout {
        send_user "\nWe timed out\n";
    }
    default {
        send_user "\nDefault exit?\n";
    }
}
expect "*please hit <return> to compile the GAMESS source code activator*" {
    send "\r";
}
expect "*Source code activator was successfully compiled.*please hit <return> to set up your network for Linux clusters.*" {
    send "\r";
}
expect "*communication library ('sockets' or 'mpi')?*" {
    # If you have a slow network, like Gigabit Ethernet (GE), or
    # if you have so few nodes you won't run extensively in parallel, or
    # if you have no MPI library installed, or
    # if you want a fail-safe compile/link and easy execution,
    #      choose 'sockets'
    # to use good old reliable standard TCP/IP networking.

    # If you have an expensive but fast network like Infiniband (IB), and
    # if you have an MPI library correctly installed,
    #      choose 'mpi'.
    send "sockets\r";
}
expect "*Optional: Build Michigan State University CCT3 & CCSD3A methods?  (yes/no):*" {
    # Users have the option of compiling the beta version of the
    # active-space CCSDt and CC(t;3) codes developed at Michigan
    # State University (CCTYP = CCSD3A and CCT3, respectively).

    # These builds take a considerable amount of time and memory for
    # compilation due to the amount of machine generated source code.
    # We recommend that users interested in installing these codes
    # compile GAMESS in parallel using the Makefile generated during
    # the initial configuration ('make -j [number of cores]').

    # This option can be manually changed later by modifying install.info
    send "no\r";
}
expect "*Do you want to try LIBCCHEM?  (yes/no):*" {
    # 64 bit Linux builds can attach a special LIBCCHEM code for fast
    # MP2 and CCSD(T) runs.  The LIBCCHEM code can utilize nVIDIA GPUs,
    # through the CUDA libraries, if GPUs are available.
    # Usage of LIBCCHEM requires installation of HDF5 I/O software as well.
    # GAMESS+LIBCCHEM binaries are unable to run most of GAMESS computations,
    # and are a bit harder to create due to the additional CUDA/HDF5 software.
    # Therefore, the first time you run 'config', the best answer is 'no'!
    # If you decide to try LIBCCHEM later, just run this 'config' again.
    send "no\r";
}
expect "*Your configuration for GAMESS compilation is now in*Now, please follow the directions in*readme.unix*" {
    send_user "We reached the end and hopefully configured GAMESS!\n"; # and we are done!
}
interact