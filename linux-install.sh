#!/bin/bash
set -e
set -o pipefail

# Choose a user account to use for this installation
get_user() {
	if [[ -z "${TARGET_USER-}" ]]; then
		mapfile -t options < <(find /home/* -maxdepth 0 -printf "%f\\n" -type d)
		# if there is only one option just use that user
		if [ "${#options[@]}" -eq "1" ]; then
			readonly TARGET_USER="${options[0]}"
            readonly TARGET_USER_HOME="/home/$TARGET_USER"
			echo "Using user account: ${TARGET_USER}"
			return
		fi

		# iterate through the user options and print them
		PS3='command -v user account should be used? '

		select opt in "${options[@]}"; do
			readonly TARGET_USER=$opt
            readonly TARGET_USER_HOME="/home/$TARGET_USER"
			break
		done
	fi
}

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
        gnupg2 \
        software-properties-common \
    )

    apt update || true
    apt install -y ${packages[@]} --no-install-recommends

    # Docker
    curl -sSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
    add-apt-repository "deb [arch=amd64] https://download.docker.com/linux/ubuntu bionic stable"

    # Kubernetes
    curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
    echo "deb https://apt.kubernetes.io/ kubernetes-xenial main" | tee /etc/apt/sources.list.d/kubernetes.list

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
        kubectl \
        hugo \
        nodejs \
        python3-pip \
        tree \
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

install_snaps(){
    snap install --classic code
    snap install --classic slack
}

install_development_tools(){
    # Golang
    curl https://dl.google.com/go/go1.14.2.linux-amd64.tar.gz -o go.tar.gz
    tar -xvf go.tar.gz
    rm -rf /usr/local/go
    mv go /usr/local
    rm go.tar.gz

    # AWS CLI
    curl https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip -o awscliv2.zip
    unzip awscliv2.zip
    ./aws/install --update
    rm -rf ./aws
    rm awscliv2.zip

    # Docker compose
    curl -L "https://github.com/docker/compose/releases/download/1.25.5/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
    chmod +x /usr/local/bin/docker-compose
    
    # JK
    curl -L https://github.com/jkcfg/jk/releases/download/0.4.0/jk-linux-amd64 -o /usr/local/bin/jk
    chmod +x /usr/local/bin/jk

    # Minikube
    curl -L https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 -o /usr/local/bin/minikube
    chmod +x /usr/local/bin/minikube

    # Zoom
    wget https://zoom.us/client/latest/zoom_amd64.deb
    apt install -y ./zoom_amd64.deb
    rm ./zoom_amd64.deb

    # Helm
    curl -L https://get.helm.sh/helm-v2.16.7-linux-amd64.tar.gz -o helm.tar.gz
    tar -xvf helm.tar.gz
    rm helm.tar.gz
    mv ./linux-amd64/helm /usr/local/bin/helm
    chmod +x /usr/local/bin/helm
    rm -rf ./linux-amd64
}

setup_zsh() {
    # Make ZSH the default shell environment
    chsh -s $(which zsh)

    ## Install oh-my-zsh
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh
    fi

    ## Install zsh-autosuggestions
    rm -rf ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
    git clone https://github.com/zsh-users/zsh-autosuggestions.git ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
}

post_install(){
    # Use docker without sudo
    groupadd -f docker
    usermod -aG docker $TARGET_USER
    
    ## Install VSCode settings
    echo "Linking $PWD/VSCode/settings.json to $TARGET_USER_HOME/.config/Code/User/settings.json"
    ln -sf $PWD/VSCode/settings.json $TARGET_USER_HOME/.config/Code/User/settings.json
    ## Install VSCode extensions
    ./code.sh
}

install_dotfiles(){
    ## Install dotfiles
    for file in $(find $PWD -type f -maxdepth 1 -name ".*" -not -name ".git"); do
        filename=$(basename $file);
        target="$TARGET_USER_HOME/$filename";
        echo "Linking $file to $target";
        ln -sf $file $target;
    done;
}

usage() {
    echo -e "linux-install.sh\\n\\tThis script installs my basic setup for a debian laptop\\n"
    echo "Usage:"
    echo "  base        - setup sources & install base pkgs, dev tools and dotfiles"
    echo "  zsh         - configure zsh"
}

main() {
    local cmd=$1

	if [[ -z "$cmd" ]]; then
		usage
		exit 1
	fi

    if [[ $cmd == "base" ]]; then
		check_is_sudo
		get_user
		setup_sources
        install_packages
        install_snaps
        install_development_tools
        install_dotfiles
        post_install
    elif [[ $cmd == "zsh" ]]; then
        setup_zsh
    else
        usage
    fi
}

main "$@"