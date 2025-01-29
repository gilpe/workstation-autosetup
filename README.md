# 💻 Workstation autosetup
Automatic setup script for my linux workstations 

## 📝 What
This repository contains resources that allows to provide to a fresh Arch Linux installation (or an existing one) 
of all the packages, applications and their configurations to turn it into a functional workstation that suits my needs.
#### Content:
 - `launch.sh` Launch the setup process after check requirements, resolve the dependencies and get the resources.
 - `setup.sh` Starts the setup process offering installation only, configuration only, or both.
 - `install.sh` Install the packages contained in the packages file and it dependencies.
 - `config.sh` Get the configuration files from _[dotfiles](https://github.com/gilpe/dotfiles)_ repo 
 and offers to overwrite the current ones.
 - `packages.txt` Plan text file with the list of packages to be installed.

> [!IMPORTANT]
As it is, These scripts are highly dependent on the _Pacman_ package manager 
so they will not work on distributions that do not contain it. 
By running this will  install, if it is not already, git for obvious reasons, 
and _[gum](https://github.com/charmbracelet/gum?tab=readme-ov-file#gum)_ to do this with style 🧐.

> [!TIP]
Keep in mind that my settings may not match with yours. 
If something doesn't suits you, consider take this as a starting point, 
review everything carefully and follow the _crafted way_ to do your own tweaks.

## 🚀 How
#### Yolo way:
Open a fresh terminal and paste:
```bash
bash <(curl -s https://raw.githubusercontent.com/gilpe/workstation-autosetup/main/launch.sh)
```
#### Crafted way:
Open a fresh terminal in a directory of your choice and paste:
```bash
git clone --depth 1 https://github.com/gilpe/workstation-autosetup.git
```
Once the tweaks have been made, grant permissions and run the _setup_ script directly: 
```bash
cd workstation-autosetup && chmod u+x ./setup.sh && ./setup.sh
```