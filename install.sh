# Installing 1Password & 1Password CLI
sudo rpm --import https://downloads.1password.com/linux/keys/1password.asc
sudo sh -c 'echo -e "[1password]\nname=1Password Stable Channel\nbaseurl=https://downloads.1password.com/linux/rpm/stable/\$basearch\nenabled=1\ngpgcheck=1\nrepo_gpgcheck=1\ngpgkey=\"https://downloads.1password.com/linux/keys/1password.asc\"" > /etc/yum.repos.d/1password.repo'
sudo dnf install -y 1password 1password-cli git
eval $(op signin)
op read op://personal/lpvmy5zudeushql4arboiunyhm/'private key' > ~/.ssh/id_ed25519
op read op://personal/lpvmy5zudeushql4arboiunyhm/'public key' > ~/.ssh/id_ed25519.pub
chmod 700 ~/.ssh/id_ed25519

# Cloning dotfiles repo
git clone --bare git@github.com:epictris/.dotfiles $HOME/.dotfiles
/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME pull origin main
/usr/bin/git --git-dir=$HOME/.dotfiles/ --work-tree=$HOME submodule update --init --recursive --remote --merge
sudo dnf install -y zsh alacritty neovim fzf chromium crudini
sudo chsh -s $(which zsh) $USER

# Installing minimal SDDM theme
sudo rm -r /usr/share/sddm/themes/minimal
sudo cp -r $HOME/.config/sddm-theme/minimal /usr/share/sddm/themes
sudo cp $HOME/.config/background.jpg /usr/share/backgrounds/background.jpg
[ ! -f /etc/sddm.conf.backup ] && sudo cp /etc/sddm.conf /etc/sddm.conf.backup
sudo crudini --set /etc/sddm.conf Theme Current minimal

# Clean up GRUB boot menu
[ ! -f /etc/default/grub.backup ] && sudo cp /etc/default/grub /etc/default/grub.backup
sudo sed -i '/^GRUB_TIMEOUT=/d' /etc/default/grub
echo 'GRUB_TIMEOUT=3' | sudo tee -a /etc/default/grub
sudo sed -i '/^GRUB_TIMEOUT_STYLE=/d' /etc/default/grub
echo 'GRUB_TIMEOUT_STYLE=hidden' | sudo tee -a /etc/default/grub
sudo grub2-mkconfig -o /boot/grub2/grub.cfg

# Install ranger with image preview
# sudo dnf install -y ranger
# sudo dnf config-manager addrepo --from-repofile=https://download.opensuse.org/repositories/home:justkidding/Fedora_42/home:justkidding.repo
# sudo dnf install -y ueberzugpp
