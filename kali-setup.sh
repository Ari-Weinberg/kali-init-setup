#!/bin/bash
set -e

# Add user to sudoers file
sudo id
USERNAME=$(whoami)
echo "[+] Adding $USERNAME to sudoers file"
echo "$USERNAME ALL=(ALL) NOPASSWD: ALL" | sudo EDITOR='tee -a' visudo

# Update and install packages, including docker CE

# Get latest debian release for docker install (https://www.kali.org/docs/containers/installing-docker-on-kali/)
echo "[+] Adding docker repo"
LATEST_DEBIAN_RELEASE=$(curl -s https://www.debian.org/releases/stable/ | grep -E '<title>Debian -- Debian &ldquo;(\w*)&rdquo; Release Information <\/title>' | sed -E 's/<title>Debian -- Debian &ldquo;(\w*)&rdquo; Release Information <\/title>/\1/')
printf '%s\n' "deb https://download.docker.com/linux/debian $LATEST_DEBIAN_RELEASE stable" | sudo tee /etc/apt/sources.list.d/docker-ce.list
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/trusted.gpg.d/docker-ce-archive-keyring.gpg

echo "[+] updating and installing pacckages"
sudo apt update
sudo apt upgrade -y
sudo apt install -y docker-ce docker-ce-cli containerd.io \
    terminator seclists curl dnsrecon enum4linux feroxbuster \
    gobuster impacket-scripts nbtscan nikto nmap onesixtyone oscanner \
    redis-tools smbclient smbmap snmp sslscan sipvicious tnscmd10g whatweb wkhtmltopdf \
    build-essential libssl-dev zlib1g-dev \
    libbz2-dev libreadline-dev libsqlite3-dev curl \
    libncursesw5-dev xz-utils tk-dev libxml2-dev libxmlsec1-dev libffi-dev liblzma-dev zsh


# Install pyenv (https://github.com/pyenv/pyenv)
echo "[+] Installing pyenv"
curl https://pyenv.run | bash

# Add user to docker group
echo "[+] adding $USERNAME to docker group"
sudo usermod -aG docker $USERNAME

# Install OMZSH
echo "[+] Installing OhMyZSH"
sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
zsh -c "git clone https://github.com/zsh-users/zsh-autosuggestions.git ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions"
zsh -c "git clone https://github.com/zsh-users/zsh-syntax-highlighting.git ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting"
sed -i 's/plugins=(git)/plugins=(git zsh-autosuggestions zsh-syntax-highlighting)/g' ~/.zshrc
sed -i 's/ZSH_THEME="robbyrussell"/ZSH_THEME="bira"/g' ~/.zshrc
sudo chsh -s $(which zsh) $USERNAME

echo "[+] Adding pyenv .zshrc"
echo 'export PYENV_ROOT="$HOME/.pyenv"' >> ~/.zshrc
echo 'command -v pyenv >/dev/null || export PATH="$PYENV_ROOT/bin:$PATH"' >> ~/.zshrc
echo 'eval "$(pyenv init -)"' >> ~/.zshrc
echo 'eval "$(pyenv virtualenv-init -)"' >> ~/.zshrc

echo "[+] Adding terminator config"
mkdir
curl -s https://raw.githubusercontent.com/Ari-Weinberg/kali-init-setup/main/terminator_config -o ~/.config/terminator/config