#!/bin/bash

# Install 1Password & 1Password CLI
sudo rpm --import https://downloads.1password.com/linux/keys/1password.asc
sudo sh -c 'echo -e "[1password]\nname=1Password Stable Channel\nbaseurl=https://downloads.1password.com/linux/rpm/stable/\$basearch\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=\"https://downloads.1password.com/linux/keys/1password.asc\"" > /etc/yum.repos.d/1password.repo'
sudo dnf install -y 1password 1password-cli git

# Fix 1Password ptrace scope issue on Fedora (https://support.1password.com/linux-ptrace-scope-issue)
sudo sed -i '/^kernel.yama.ptrace_scope/d' /etc/sysctl.conf
sudo sysctl -w kernel.yama.ptrace_scope=1 | sudo tee -a /etc/sysctl.conf

# Authenticate with 1Password
eval $(op signin)
op read op://personal/lpvmy5zudeushql4arboiunyhm/'private key' > ~/.ssh/id_ed25519
op read op://personal/lpvmy5zudeushql4arboiunyhm/'public key' > ~/.ssh/id_ed25519.pub
chmod 700 ~/.ssh/id_ed25519

# Install Yazi
sudo dnf copr enable lihaohong/yazi
sudo dnf install -y zsh neovim fzf chromium crudini yazi
sudo chsh -s $(which zsh) $USER

# Clone dotfiles repo
git clone --bare git@github.com:epictris/.dotfiles $HOME/.dotfiles 2>/dev/null
/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME pull origin main
/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME submodule update --init --recursive --remote --merge

# Install minimal SDDM theme
sudo rm -r /usr/share/sddm/themes/minimal
sudo cp -r $HOME/.config/sddm-theme/minimal /usr/share/sddm/themes
sudo cp $HOME/.config/background.jpg /usr/share/backgrounds/background.jpg
[ ! -f /etc/sddm.conf.backup ] && sudo cp /etc/sddm.conf /etc/sddm.conf.backup
sudo crudini --set /etc/sddm.conf Theme Current minimal

# Clean up GRUB boot menu
[ ! -f /etc/default/grub.backup ] && sudo cp /etc/default/grub /etc/default/grub.backup
sudo sed -i '/^GRUB_TIMEOUT=/d' /etc/default/grub
sudo sed -i '/^GRUB_TIMEOUT_STYLE=/d' /etc/default/grub
sudo echo 'GRUB_TIMEOUT=3' | sudo tee -a /etc/default/grub
sudo echo 'GRUB_TIMEOUT_STYLE=hidden' | sudo tee -a /etc/default/grub
sudo grub2-mkconfig -o /boot/grub2/grub.cfg
