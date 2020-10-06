#!/bin/sh

echo "Setting up your Mac..."

# Check for Homebrew and install if we don't have it
if test ! $(which brew); then
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

readonly KUBEBUILDER_VERSION=2.3.1
readonly POLARIS_VERSION=1.2.1
readonly GOTK_VERSION=0.1.4

# Update Homebrew recipes
brew update --force

# Install all our dependencies with bundle (See Brewfile)
brew tap homebrew/bundle
brew bundle
brew bundle cleanup --force

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

  # Install spaceship-prompt
  rm -rf ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/spaceship-prompt
  git clone --depth=1 https://github.com/denysdovhan/spaceship-prompt.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/spaceship-prompt
  ln -s ${ZSH_CUSTOM:-~/.oh-my-zsh/custom/}/themes/spaceship-prompt/spaceship.zsh-theme ${ZSH_CUSTOM:-~/.oh-my-zsh/custom/}/themes/spaceship.zsh-theme
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
      target="$HOME/$filename";
      echo "Linking $file to $target";
      ln -sf $file $target;
  done;
}

post_install() {
  ## Install VSCode settings
  echo "Linking $PWD/VSCode/settings.json to $HOME/Library/Application\ Support/Code/User/settings.json"
  ln -sf $PWD/VSCode/settings.json $HOME/Library/Application\ Support/Code/User/settings.json

  # Kubebuilder
  curl -L "https://go.kubebuilder.io/dl/${KUBEBUILDER_VERSION}/darwin/amd64" | tar -xz -C /tmp/
  sudo rm -rf /usr/local/kubebuilder
  sudo mv /tmp/kubebuilder_${KUBEBUILDER_VERSION}_darwin_amd64 /usr/local/kubebuilder

  # Polaris
  curl -L "https://github.com/FairwindsOps/polaris/releases/download/${POLARIS_VERSION}/polaris_${POLARIS_VERSION}_darwin_amd64.tar.gz" | tar -xz -C /tmp
  sudo rm -rf /usr/local/bin/polaris
  sudo mv /tmp/polaris /usr/local/bin/polaris

  # GOTK
  curl -L "https://github.com/fluxcd/toolkit/releases/download/v${GOTK_VERSION}/gotk_${GOTK_VERSION}_darwin_amd64.tar.gz" | tar -xz -C /tmp
  sudo rm -rf /usr/local/bin/gotk
  sudo mv /tmp/gotk /usr/local/bin/gotk

  # Ginkgo
  /usr/local/bin/go get -u github.com/onsi/ginkgo/ginkgo
  # Cobra
  /usr/local/bin/go get -u github.com/spf13/cobra/cobra

  ## Install VSCode extensions
  code --install-extension timonwong.shellcheck
  code --install-extension golang.Go
  code --install-extension ms-kubernetes-tools.vscode-kubernetes-tools
  code --install-extension MS-vsliveshare.vsliveshare-pack
  code --install-extension foam.foam-vscode
  code --install-extension james-yu.latex-workshop
}

main() {
  setup_zsh
  setup_vim
  install_dotfiles
  post_install
}

main

brew upgrade
brew cleanup

