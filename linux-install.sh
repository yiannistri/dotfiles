#!/bin/bash
set -euo pipefail

readonly GO_VERSION=1.14.4
readonly FOOTLOOSE_VERSION=0.5.0
readonly TERRAFORM_VERSION=0.11.10
readonly KUBEBUILDER_VERSION=2.3.1

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
        ansible \
        blueman \
        brave-browser \
        containerd.io \
        curl \
        direnv \
        docker-ce \
        docker-ce-cli \
        fonts-firacode \
        fonts-powerline \
        git \
        google-cloud-sdk \
        jq \
        kubectl \
        hugo \
        nodejs \
        python-is-python3 \
        python3-pip \
        tree \
        vim \
        vlc \
        wavemon \
        yarn \
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
    snap install --classic skype
    snap install yq
}

install_development_tools(){
    # Golang
    curl "https://dl.google.com/go/go${GO_VERSION}.linux-amd64.tar.gz" -o go.tar.gz
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

    # AWS IAM Authenticator
    curl -L https://amazon-eks.s3.us-west-2.amazonaws.com/1.16.8/2020-04-16/bin/linux/amd64/aws-iam-authenticator -o /usr/local/bin/aws-iam-authenticator
    chmod +x /usr/local/bin/aws-iam-authenticator

    # eksctl
    curl -L "https://github.com/weaveworks/eksctl/releases/latest/download/eksctl_$(uname -s)_amd64.tar.gz" | tar xz -C /tmp
    mv /tmp/eksctl /usr/local/bin

    # Footloose
    curl -L "https://github.com/weaveworks/footloose/releases/download/${FOOTLOOSE_VERSION}/footloose-${FOOTLOOSE_VERSION}-linux-x86_64" -o /usr/local/bin/footloose
    chmod +x /usr/local/bin/footloose

    # Terraform
    curl -L "https://releases.hashicorp.com/terraform/${TERRAFORM_VERSION}/terraform_${TERRAFORM_VERSION}_linux_amd64.zip" -o terraform.zip
    unzip terraform.zip
    mv terraform /usr/local/bin/terraform
    chmod +x /usr/local/bin/terraform
    rm terraform.zip

    curl -L "https://go.kubebuilder.io/dl/${KUBEBUILDER_VERSION}/linux/amd64" | tar -xz -C /tmp/
    rm -rf /usr/local/kubebuilder
    mv /tmp/kubebuilder_${KUBEBUILDER_VERSION}_linux_amd64 /usr/local/kubebuilder

    (
        set -x
        set +e
        
        # Embedmd
        /usr/local/go/bin/go get github.com/campoy/embedmd
    )
}

setup_zsh() {
    # Make ZSH the default shell environment
    chsh -s $(which zsh)

    ## Install oh-my-zsh
    if [ ! -d "$HOME/.oh-my-zsh" ]; then
        curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh
    fi

    ## Install zsh-autosuggestions
    rm -rf ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
    git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

    ## Install Powerlevel10k
    rm -rf ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/powerlevel10k

    mkdir -p ~/.local/share/fonts
    cd ~/.local/share/fonts
    curl -fLo "MesloLGS NF Regular.ttf" https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Regular.ttf
    curl -fLo "MesloLGS NF Bold.ttf" https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold.ttf
    curl -fLo "MesloLGS NF Italic.ttf" https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Italic.ttf
    curl -fLo "MesloLGS NF Bold Italic.ttf" https://github.com/romkatv/powerlevel10k-media/raw/master/MesloLGS%20NF%20Bold%20Italic.ttf

    curl -fLo "Source Code Pro Italic" https://github.com/adobe-fonts/source-code-pro/releases/download/variable-fonts/SourceCodeVariable-Italic.ttf
    curl -fLo "Source Code Pro Bold" https://github.com/adobe-fonts/source-code-pro/releases/download/variable-fonts/SourceCodeVariable-Roman.ttf
}

setup_vim() {
    ## Setup vim
    mkdir -p ~/.vim/autoload ~/.vim/bundle
    curl -LSso ~/.vim/autoload/pathogen.vim https://tpo.pe/pathogen.vim
    rm -rf ~/.vim/bundle/vim-colors-solarized
    git clone https://github.com/altercation/vim-colors-solarized.git ~/.vim/bundle/vim-colors-solarized
    rm -rf ~/.vim/bundle/nerdtree
    git clone https://github.com/scrooloose/nerdtree.git ~/.vim/bundle/nerdtree
    rm -rf ~/.vim/bundle/vim-fugitive
    git clone https://github.com/tpope/vim-fugitive.git ~/.vim/bundle/vim-fugitive
    rm -rf ~/.vim/bundle/syntastic
    git clone https://github.com/scrooloose/syntastic.git ~/.vim/bundle/syntastic
    rm -rf ~/.vim/bundle/vim-devicons
    git clone https://github.com/ryanoasis/vim-devicons ~/.vim/bundle/vim-devicons
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
        setup_vim
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