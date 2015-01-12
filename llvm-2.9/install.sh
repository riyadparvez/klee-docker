#! /bin/bash

# KLEE install script.
#
# Sets up llvm-gcc 4.2, llvm 2.9, upstream STP, 0_9_29 klee-uclibc (currently upstream), and upstream KLEE.
#
# Based on http://klee.github.io/klee/GetStarted.html and threads from  https://www.mail-archive.com/klee-dev@imperial.ac.uk
# 
# Tested on 64-bit Ubuntu 14.04.
#
# On Ubuntu 12.04, cmake 2.8.8 or higher, e.g. 2.8.12.2 has to be installed ( How-to: 
# http://cameo54321.blogspot.com/2014/02/installing-cmake-288-or-higher-on.html )
#
# Author: Emil Rakadjiev <emil.rakadjiev...@hitachi.com>

if [ ! -z "$1" ]
then
        BASEDIR="$1"
else
        BASEDIR="klee"
fi

mkdir -p "$BASEDIR"
BASEDIR=$(cd $BASEDIR; pwd)
echo "Installing KLEE and dependencies to ${BASEDIR}"

# Install required packages
sudo apt-get update
sudo apt-get install -y build-essential curl python-minimal git bison flex bc libcap-dev git cmake libboost-all-dev valgrind libm4ri-dev libmysqlclient-dev libsqlite3-dev libtbb-dev libncurses5-dev

# Persist environment variables
sudo sh -c 'echo "export C_INCLUDE_PATH=/usr/include/x86_64-linux-gnu" > /etc/profile.d/kleevars.sh'
sudo sh -c 'echo "export CPLUS_INCLUDE_PATH=/usr/include/x86_64-linux-gnu" >>  /etc/profile.d/kleevars.sh'
. "/etc/profile.d/kleevars.sh"

# Install llvm-gcc
cd "$BASEDIR"
curl -4OL 'http://llvm.org/releases/2.9/llvm-gcc4.2-2.9-x86_64-linux.tar.bz2'
sudo tar -xjf "llvm-gcc4.2-2.9-x86_64-linux.tar.bz2" -C "/usr/local/"
sudo sh -c 'echo "export PATH=\$PATH:/usr/local/llvm-gcc4.2-2.9-x86_64-linux/bin" >> /etc/profile.d/kleevars.sh'
. "/etc/profile.d/kleevars.sh"

# Install llvm
curl -4OL 'http://llvm.org/releases/2.9/llvm-2.9.tgz'
rm -rf "${BASEDIR}/llvm-2.9"
tar -xzf "llvm-2.9.tgz"
# See: https://www.mail-archive.com/klee-dev@imperial.ac.uk/msg01302.html
curl -4OL 'http://www.mail-archive.com/klee-dev@imperial.ac.uk/msg01302/unistd-llvm-2.9-jit.patch'
patch "llvm-2.9/lib/ExecutionEngine/JIT/Intercept.cpp" "unistd-llvm-2.9-jit.patch"
cd "${BASEDIR}/llvm-2.9"
./configure --enable-optimized --enable-assertions
make
sudo sh -c 'echo "export PATH=\$PATH:'"$BASEDIR"'/llvm-2.9/Release+Asserts/bin" >> /etc/profile.d/kleevars.sh'
. "/etc/profile.d/kleevars.sh"

# Install stp
cd "$BASEDIR"
rm -rf "${BASEDIR}/stp"
git clone 'https://github.com/stp/stp.git'
mkdir "${BASEDIR}/stp/build"
cd "${BASEDIR}/stp/build"
# Upstream STP builds shared libraries by default, which causes problems for KLEE, so we disable them 
# (see: https://www.mail-archive.com/klee-dev@imperial.ac.uk/msg01704.html )
# The Python interface requires shared libraries, so we have to disable that, too. This 
# disables testing, but we normally don't want to run STP tests anyway.
cmake -DBUILD_SHARED_LIBS:BOOL=OFF -DENABLE_PYTHON_INTERFACE:BOOL=OFF ..
make OPTIMIZE=-O2 CFLAGS_M32=
sudo make install
# TODO for persisting the stack size limit, customize /etc/security/limits.conf
# "nofile" limit should normally be increased, too
ulimit -s unlimited

# Install klee-uclibc
cd "$BASEDIR"
rm -rf "${BASEDIR}/klee-uclibc"
git clone --depth 1 --branch klee_0_9_29 'https://github.com/klee/klee-uclibc.git'
cd "${BASEDIR}/klee-uclibc"
./configure --make-llvm-lib
make -j

# Install klee
cd "$BASEDIR"
rm -rf "${BASEDIR}/klee"
git clone 'https://github.com/klee/klee.git'
mkdir "${BASEDIR}/klee/build"
cd "${BASEDIR}/klee/build"
../configure --with-llvm="${BASEDIR}/llvm-2.9" --with-stp="${BASEDIR}/stp/build" --with-uclibc="${BASEDIR}/klee-uclibc" --enable-posix-runtime
make ENABLE_OPTIMIZED=1
sudo sh -c 'echo "export PATH=\$PATH:'"${BASEDIR}/klee/build/Release+Asserts/bin"'" >> /etc/profile.d/kleevars.sh'

# Run klee tests
make check
make unittests
