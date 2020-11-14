#!/bin/sh

echo "Setting up your Mac..."

# Check for Homebrew and install if we don't have it
if test ! $(which brew); then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
fi

readonly KUBEBUILDER_VERSION=2.3.1
readonly POLARIS_VERSION=1.2.1
readonly FLUX2_VERSION=0.2.5
readonly SONOBUOY_VERSION=0.19.0
readonly JK_VERSION=0.4.0

# Update Homebrew recipes
brew update --force

# Install all our dependencies with bundle (See Brewfile)
brew tap homebrew/bundle
brew bundle --no-lock
brew bundle cleanup --force

setup_zsh() {
  ## Install oh-my-zsh
  if [ ! -d "$HOME/.oh-my-zsh" ]; then
    curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh
  fi

  ## Install zsh-autosuggestions
  rm -rf ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions
  git clone --depth=1 https://github.com/zsh-users/zsh-autosuggestions.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/zsh-autosuggestions

  # Install spaceship-prompt
  rm -rf ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/spaceship-prompt
  git clone --depth=1 https://github.com/denysdovhan/spaceship-prompt.git ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/spaceship-prompt
  ln -s ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/spaceship-prompt/spaceship.zsh-theme ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/themes/spaceship.zsh-theme
}

setup_vim() {
  # Setup vim
  mkdir -p ~/.vim/pack/plugins/start
  rm -rf ~/.vim/pack/plugins/start/vim-colors-solarized
  git clone https://github.com/altercation/vim-colors-solarized.git ~/.vim/pack/plugins/start/vim-colors-solarized
  rm -rf ~/.vim/pack/plugins/start/nerdtree
  git clone https://github.com/scrooloose/nerdtree.git ~/.vim/pack/plugins/start/nerdtree
  rm -rf ~/.vim/pack/plugins/start/vim-fugitive
  git clone https://github.com/tpope/vim-fugitive.git ~/.vim/pack/plugins/start/vim-fugitive
  rm -rf ~/.vim/pack/plugins/start/syntastic
  git clone https://github.com/scrooloose/syntastic.git ~/.vim/pack/plugins/start/syntastic
  rm -rf ~/.vim/pack/plugins/start/ctrlp.vim
  git clone https://github.com/ctrlpvim/ctrlp.vim.git ~/.vim/pack/plugins/start/ctrlp.vim
  rm -rf ~/.vim/pack/plugins/start/vim-devicons
  git clone https://github.com/ryanoasis/vim-devicons ~/.vim/pack/plugins/start/vim-devicons  
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

  # Flux2
  curl -L "https://github.com/fluxcd/flux2/releases/download/v${FLUX2_VERSION}/flux_${FLUX2_VERSION}_darwin_amd64.tar.gz" | tar -xz -C /tmp
  sudo rm -rf /usr/local/bin/flux
  sudo mv /tmp/flux /usr/local/bin/flux

  # Sonobuoy
  curl -L "https://github.com/vmware-tanzu/sonobuoy/releases/download/v${SONOBUOY_VERSION}/sonobuoy_${SONOBUOY_VERSION}_darwin_amd64.tar.gz" | tar -xz -C /tmp
  sudo rm -rf /usr/local/bin/sonobuoy
  sudo mv /tmp/sonobuoy /usr/local/bin/sonobuoy

  # JK
  curl -L "https://github.com/jkcfg/jk/releases/download/${JK_VERSION}/jk-darwin-amd64" -o /usr/local/bin/jk
  chmod +x /usr/local/bin/jk

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

