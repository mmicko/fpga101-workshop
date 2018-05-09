# FPGA 101 - Workshop materials

This repo contains all needed material for participation at FPGA 101 Workshop at Hackaday event in Belgrade 26th of May 2018.

# Linux Install

First install required packages.

For Ubuntu use :
```console
sudo apt install python-pip make git
```

Also install Node.JS
```console
curl -sL https://deb.nodesource.com/setup_8.x -o nodesource_setup.sh
sudo bash nodesource_setup.sh
sudo apt-get install nodejs
```

Download prepared package, adn install APIO
```console
cd ~

wget https://github.com/mmicko/fpga101-workshop/releases/download/tools/fpga101-linux-x64-tools.tar.gz

tar xvfz fpga101-linux-x64-tools.tar.gz

cd hackaday-fpga101

source fpga101.sh

cd apio

sudo pip install -e .

cd ../icestudio
npm install
```

Test if all is setup correctly
```console
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

# macOS Install
