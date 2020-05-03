#!/bin/bash
set -e
set -o pipefail

check_is_sudo() {
	if [ "$EUID" -ne 0 ]; then
		echo "Please run as root."
		exit
	fi
}

setup_sources() {
    local -a packages; packages=( \
        apt-transport-https \
        ca-certificates \
        curl \
        software-properties-common \
    )

    apt update || true
    apt install -y ${packages[@]} --no-install-recommends

    # Docker
    curl -sSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"

    # Google cloud sdk
    curl -sS https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key --keyring /usr/share/keyrings/cloud.google.gpg add -
    echo "deb [signed-by=/usr/share/keyrings/cloud.google.gpg] http://packages.cloud.google.com/apt cloud-sdk main" | tee /etc/apt/sources.list.d/google-cloud-sdk.list

    # Brave browser
    curl -sS https://brave-browser-apt-release.s3.brave.com/brave-core.asc | apt-key --keyring /etc/apt/trusted.gpg.d/brave-browser-release.gpg add -
    echo "deb [arch=amd64] https://brave-browser-apt-release.s3.brave.com/ stable main" | tee /etc/apt/sources.list.d/brave-browser-release.list
    
    # NodeJS
    curl -sSL https://deb.nodesource.com/setup_12.x | bash -

    # Yarn
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
}

install_packages(){
    local -a packages; packages=( \
        brave-browser \
        containerd.io \
        curl \
        direnv \
        docker-ce \
        docker-ce-cli \
        fonts-powerline \
        git \
        google-cloud-sdk \
        hugo \
        nodejs \
        python3-pip \
        yarn \
        vim \
        zsh \
    )

    apt update || true
    apt upgrade -y
    apt install -y ${packages[@]}

    apt autoremove -y
    apt autoclean
    apt clean
}

install_development_tools(){
    curl -O https://dl.google.com/go/go1.14.2.linux-amd64.tar.gz
    tar -xvf go1.14.2.linux-amd64.tar.gz
    sudo rm -rf /usr/local/go
    sudo mv go /usr/local
    rm go1.14.2.linux-amd64.tar.gz

sudo snap install --classic code

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install --update
rm -rf ./aws
rm awscliv2.zip

    sudo groupadd docker && sudo usermod -aG docker $
    
    sudo curl -L "https://github.com/docker/compose/releases/download/1.25.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    sudo chmod +x /usr/local/bin/docker-compose
}

setup_zsh() {
install_essential_packages
install_development_tools

# Make ZSH the default shell environment
chsh -s $(which zsh)

## Install oh-my-zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh
fi

## Install zsh-autosuggestions
rm -rf ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
git clone https://github.com/zsh-users/zsh-autosuggestions.git ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions

## Install dotfiles
for file in $(find $PWD -type f -maxdepth 1 -name ".*" -not -name ".git"); do
    filename=$(basename $file);
    target="$HOME/$filename";
    echo "Linking $file to $target";
    ln -sf $file $target;
done;

}

usage() {
    echo -e "linux-install.sh\\n\\tThis script installs my basic setup for a debian laptop\\n"
    echo "Usage:"
    echo "  base   - setup sources & install base pkgs"
}

main() {
    local cmd=$1

	if [[ -z "$cmd" ]]; then
		usage
		exit 1
	fi

    if [[ $cmd == "base" ]]; then
		check_is_sudo
		# setup /etc/apt/sources.list
		setup_sources
        install_packages
    fi
}

main "$@"