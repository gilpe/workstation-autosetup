# 💻 Workstation autosetup
Automatic setup script for my linux workstations 

> [!WARNING]
Please, remember that my base system and preferences may not match with yours. The setup script and the chosen packages are set for an Arch Linux based installation that work for me.

## 🚀 Run
Open a fresh terminal and paste:
```bash
bash <(curl -s https://raw.githubusercontent.com/gilpe/workstation-autosetup/main/launch.sh)
```
#### Crafted way:
If something doesn't suits you, clone the whole repo: 
```bash
git clone --depth 1 https://github.com/gilpe/workstation-autosetup.git
```
and after doing your tweaking, grant permissions and run the _setup_ script directly: 
```bash
cd workstation-autosetup && chmod u+x ./setup.sh && ./setup.sh
```