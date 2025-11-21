#!/bin/bash

# 1. "Exit Immediately" Mode
# This ensures that if a download fails or a compilation errors out,
# the script stops instantly so you don't end up with a broken install.
set -e

echo ">>> STARTING OS TOOLCHAIN INSTALLATION <<<"

# 2. Set Up Variables
export PREFIX="/usr/local/i386elfgcc"
export TARGET=i386-elf
export PATH="$PREFIX/bin:$PATH"
export WORK_DIR="$HOME/src_toolchain"

# Create a fresh workspace
echo ">>> Creating workspace at $WORK_DIR..."
mkdir -p "$WORK_DIR"
cd "$WORK_DIR"

# 3. Install dependencies
echo ">>> Installing dependencies..."
sudo apt update
sudo apt install -y build-essential bison flex libgmp3-dev libmpc-dev libmpfr-dev texinfo libncurses-dev

# ---------------------------------------------------------
# PHASE 1: BINUTILS (Modern Version 2.45.1)
# ---------------------------------------------------------
echo ">>> Downloading Binutils 2.45.1..."
curl -O https://ftp.gnu.org/gnu/binutils/binutils-2.45.1.tar.xz
tar xf binutils-2.45.1.tar.xz

echo ">>> Building Binutils..."
mkdir -p binutils-build
cd binutils-build
../binutils-2.45.1/configure --target=$TARGET --enable-interwork --enable-multilib --disable-nls --disable-werror --prefix=$PREFIX

make -j$(nproc) 
# -j$(nproc) uses all CPU cores to compile faster

echo ">>> Installing Binutils..."
sudo make install
cd "$WORK_DIR"

# ---------------------------------------------------------
# PHASE 2: GCC (Version 4.9.1 - Patched for Modern Linux)
# ---------------------------------------------------------
echo ">>> Downloading GCC 4.9.1..."
curl -O https://ftp.gnu.org/gnu/gcc/gcc-4.9.1/gcc-4.9.1.tar.bz2
tar xf gcc-4.9.1.tar.bz2

echo ">>> Building GCC (This will take a while)..."
mkdir -p gcc-build
cd gcc-build

# Configure with CXXFLAGS to fix the C++17 compatibility issue
../gcc-4.9.1/configure --target=$TARGET --prefix="$PREFIX" --disable-nls --disable-libssp --enable-languages=c --without-headers CXXFLAGS="-g -O2 -std=gnu++98"

make all-gcc -j$(nproc)
make all-target-libgcc -j$(nproc)

echo ">>> Installing GCC..."
sudo make install-gcc
sudo make install-target-libgcc
cd "$WORK_DIR"

# ---------------------------------------------------------
# PHASE 3: GDB (Modern Version 9.2)
# ---------------------------------------------------------
echo ">>> Downloading GDB 9.2..."
curl -O https://ftp.gnu.org/gnu/gdb/gdb-9.2.tar.xz
tar xf gdb-9.2.tar.xz

echo ">>> Building GDB..."
mkdir -p gdb-build
cd gdb-build
../gdb-9.2/configure --target="$TARGET" --prefix="$PREFIX" --program-prefix=i386-elf- --disable-werror

make -j$(nproc)

echo ">>> Installing GDB..."
sudo make install
cd "$WORK_DIR"

# ---------------------------------------------------------
# FINISH: Cleanup and Persistence
# ---------------------------------------------------------
echo ">>> Cleaning up source files..."
cd $HOME
rm -rf "$WORK_DIR"

echo ">>> Making PATH permanent..."
# Only add to bashrc if it's not already there
if ! grep -q "/usr/local/i386elfgcc/bin" ~/.bashrc; then
  echo 'export PATH="$PATH:/usr/local/i386elfgcc/bin"' >> ~/.bashrc
  echo "Path added to .bashrc"
else
  echo "Path already exists in .bashrc"
fi

echo "-----------------------------------------------------"
echo "SUCCESS! Your toolchain is installed."
echo "Please close this terminal and open a new one."
echo "Then type: i386-elf-gcc --version"
echo "-----------------------------------------------------"