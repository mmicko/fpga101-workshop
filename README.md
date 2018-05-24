# FPGA 101 - Workshop materials

This repo contains all needed material for participation at FPGA 101 Workshop at Hackaday event in Belgrade 26th of May 2018.

# For all environments

You probably already have a favorite text editor on your computer ready, but in case it does not 
have Verilog language syntax hightlight, that could help you at least at start, install Visual Studio Code or
Atom or any similar editor supporting it.

For Visual Studio Code use:

```console
ext install mshr-h.VerilogHDL
```
For Atom use:

```console
apm install language-verilog
```

# Linux Install

First install required packages.

For Ubuntu use :
```console
sudo apt install python-pip make git gtkwave curl
```

Also install Node.JS
```console
curl -sL https://deb.nodesource.com/setup_8.x -o nodesource_setup.sh
sudo bash nodesource_setup.sh
sudo apt-get install nodejs
```

Download prepared package, and install APIO
```console
cd ~

wget https://github.com/mmicko/fpga101-workshop/releases/download/tools/fpga101-linux-x64-tools.tar.gz

tar xvfz fpga101-linux-x64-tools.tar.gz

cd hackaday-fpga101

source fpga101.sh

cd apio

sudo pip install -e .
```

Install needed Node.JS packages for IceStudio

```console
cd ../icestudio
npm install
```

# Windows Install

Download file from [this link](https://github.com/mmicko/fpga101-workshop/releases/download/tools/fpga101-windows-x64-tools.7z) first.

Uze 7zip (can be downloaded from [here](https://www.7-zip.org/download.html)) to unpack file (using right click -> 7-Zip -> Extract here )

Move that folder to root of C drive (mandatory due to location being hardcoded in part of msys install)

Go to c:\msys64  and click ConEmu.exe to get console.

Your profile will be generated and you will be greeted by next prompt.

```console
[HACKADAY] C:\msys64\src>
```

If you do not already have installed you favorite terminal console for serial access, please install [PuTTY](https://www.putty.org/) or similar.
You can even install it from command line by using:

```console
pacman -S mingw-w64-x86_64-putty
```

# macOS Install

First install Homebrew to be able to install rest of packages.

```console
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

Then you will be able to install Python 3, Node.JS and GTKWave
```console
brew install python
brew install node
brew install wget

brew cask install gtkwave
```

Download prepared package, and install APIO
```console
cd ~

wget https://github.com/mmicko/fpga101-workshop/releases/download/tools/fpga101-darwin-x64-tools.tar.gz

tar xvfz fpga101-darwin-x64-tools.tar.gz

cd hackaday-fpga101

source fpga101.sh

cd apio

sudo pip3 install -e .
```

Install needed Node.JS packages for IceStudio

```console
cd ../icestudio
npm install
```

# Workshop materials

To be able to test environment and to have starting point for workshop you also need to download this repository.

```console
git clone https://github.com/mmicko/fpga101-workshop
```

**NOTE** In case you are getting error on git utility on Windows, first run msys but just leave it open at side, and try again in main window:
```console
c:\msys64\msys2.exe
```

In examples down listed, assumption is that on Linux and macOS all is downloaded in user home folder, and on Windows in c:\msys64\src folder.

# Testing

For Linux and macOS always make sure you have tools setup and initialized first.

```console
source ~/hackaday-fpga101/fpga101.sh
```

## Testing APIO environment

To test if all is setup correctly.

```console

cd fpga101-workshop/tests/led

apio build

```
response should be

```console

[xxx xxx x hh:mm:ss yyyy] Processing fpga101
--------------------------------------------------------------------------------
yosys -p "synth_ice40 -blif hardware.blif" -q led.v
arachne-pnr -d 5k -P sg48 -p pinout.pcf -o hardware.asc -q hardware.blif
icepack hardware.asc hardware.bin
========================= [SUCCESS] Took 1.07 seconds =========================
```

To check if GTKWave is installed fine use (on macOS it will be as separate application so we will use it manually)

```console
apio sim
```
And that would open GTKWave with simulation file.

## Testing Risc-V compiler

```console
cd ~
cd fpga101-workshop/tests/riscv
make
```
response should be

```console
riscv64-unknown-elf-gcc -O3 -nostartfiles -mabi=ilp32 -march=rv32ic -Wl,-Bstatic,-T,sections.lds,--strip-debug -ffreestanding -o firmware.elf start.s sections.c firmware.c -lgcc
riscv64-unknown-elf-objcopy  -O binary firmware.elf firmware.bin
```

## Testing IceStudio

For Linux and macOS:
```console
cd ~
cd hackaday-fpga101/icestudio
npm start
```

For Windows:
```console
cd \msys64\opt\icestudio 
npm start
```

Should start nw.js with IceStudio running.


