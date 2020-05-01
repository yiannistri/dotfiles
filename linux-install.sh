#!/bin/bash

install_essential_packages(){
    local -a packages; packages=( \
        git curl python3-pip \
        vim zsh direnv \
        fonts-powerline \
    )

    sudo apt update
    sudo apt upgrade -y
    sudo apt install -y ${packages[@]}
}

install_essential_packages

sudo snap install --classic code

curl "https://awscli.amazonaws.com/awscli-exe-linux-x86_64.zip" -o "awscliv2.zip"
unzip awscliv2.zip
sudo ./aws/install --update
rm -rf ./aws
rm awscliv2.zip

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
