#!/bin/bash

echo -e "\n"
echo "Installing essential packages"
echo "==============================================================================="
echo -e "\n"

sudo apt-get update
sudo apt-get -y upgrade
sudo apt-get install -y build-essential curl git bison flex bc libcap-dev git cmake libboost-all-dev libncurses5-dev python-minimal python-pip unzip wget llvm-3.4-dev clang
sudo ln -sf /usr/bin/llvm-config-3.4 /usr/bin/llvm-config

export C_INCLUDE_PATH=/usr/include/x86_64-linux-gnu  
export CPLUS_INCLUDE_PATH=/usr/include/x86_64-linux-gnu

mkdir deps
cd deps

echo -e "\n"
echo "Building STP"
echo "==============================================================================="
echo -e "\n"

git clone https://github.com/stp/stp.git  
mkdir stp/build  
cd stp/build
cmake -DBUILD_SHARED_LIBS:BOOL=OFF -DENABLE_PYTHON_INTERFACE:BOOL=OFF ..  
make  
sudo make install  
cd ../..
ulimit -s unlimited

echo -e "\n"
echo "Building uclibc"
echo "==============================================================================="
echo -e "\n"

git clone https://github.com/klee/klee-uclibc.git  
cd klee-uclibc  
./configure --make-llvm-lib  
make -j
cd .. 

echo -e "\n"
echo "Building Google-Test"
echo "==============================================================================="
echo -e "\n"

curl -OL https://googletest.googlecode.com/files/gtest-1.7.0.zip  
unzip gtest-1.7.0.zip  
cd gtest-1.7.0  
cmake .  
make  
cd ..

echo -e "\n"
echo "Building LLVM-3.4"
echo "==============================================================================="
echo -e "\n"

wget http://llvm.org/releases/3.4.2/llvm-3.4.2.src.tar.gz
tar -zxvf llvm-3.4.2.src.tar.gz
cd llvm-3.4.2.src
mkdir build
cd build
../configure --enable-optimized
make
cd ../../..

export PATH=$PATH:$(pwd)/deps/llvm-3.4.2.src/build/Release+Asserts/bin
export CXXFLAGS='-I$(pwd)/deps/llvm-3.4.2.src/include'
export LDFLAGS='-L$(pwd)/deps/llvm-3.4.2.src/build/Release+Asserts/lib'

echo -e "\n"
echo "Building KLEE"
echo "==============================================================================="
echo -e "\n"

git clone https://github.com/klee/klee.git
cd klee
mkdir build  
cd build  
../configure --with-stp=$(pwd)/../../deps/stp/build --with-uclibc=$(pwd)/../../deps/klee-uclibc --with-llvmsrc=$(pwd)/../../deps/llvm-3.4.2.src --with-llvmobj=$(pwd)/../../deps/llvm-3.4.2.src/build --enable-posix-runtime 
  
make DISABLE_ASSERTIONS=0 ENABLE_OPTIMIZED=1 ENABLE_SHARED=0 -j2
