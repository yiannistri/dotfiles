#!/bin/sh

echo "Setting up your Mac..."

# Check for Homebrew and install if we don't have it
if test ! $(which brew); then
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install.sh)"
fi

readonly CLUSTERCTL_VERSION=0.3.19
readonly FLUX2_VERSION=0.12.1
readonly JK_VERSION=0.4.0
readonly KUBEBUILDER_VERSION=2.3.2
readonly KUBECTL_VERSION=1.17.17
readonly PCTL_VERSION=0.0.2
readonly POLARIS_VERSION=3.1.3
readonly SONOBUOY_VERSION=0.19.0
readonly WEGO_VERSION=0.0.5

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
  echo "Installing kubebuilder ${KUBEBUILDER_VERSION}"
  curl -L "https://go.kubebuilder.io/dl/${KUBEBUILDER_VERSION}/darwin/amd64" | tar -xz -C /tmp/
  sudo rm -rf /usr/local/kubebuilder
  sudo mv /tmp/kubebuilder_${KUBEBUILDER_VERSION}_darwin_amd64 /usr/local/kubebuilder

  # kubectl
  echo "Installing kubectl ${KUBECTL_VERSION}"
  curl -L "https://dl.k8s.io/release/v${KUBECTL_VERSION}/bin/darwin/amd64/kubectl" -o /usr/local/bin/kubectl
  chmod +x /usr/local/bin/kubectl

  # Polaris
  echo "Installing Polaris ${POLARIS_VERSION}"
  curl -L "https://github.com/FairwindsOps/polaris/releases/download/${POLARIS_VERSION}/polaris_${POLARIS_VERSION}_darwin_amd64.tar.gz" | tar -xz -C /tmp
  sudo rm -rf /usr/local/bin/polaris
  sudo mv /tmp/polaris /usr/local/bin/polaris

  # Flux2
  echo "Installing flux2 ${FLUX2_VERSION}"
  curl -L "https://github.com/fluxcd/flux2/releases/download/v${FLUX2_VERSION}/flux_${FLUX2_VERSION}_darwin_amd64.tar.gz" | tar -xz -C /tmp
  sudo rm -rf /usr/local/bin/flux
  sudo mv /tmp/flux /usr/local/bin/flux

  # pctl
  echo "Installing pctl ${PCTL_VERSION}"
  curl -L "https://github.com/weaveworks/pctl/releases/download/v${PCTL_VERSION}/pctl_darwin_amd64.tar.gz" | tar -xz -C /tmp
  sudo rm -rf /usr/local/bin/pctl
  sudo mv /tmp/pctl /usr/local/bin/pctl

  # Sonobuoy
  echo "Installing sonobuoy ${SONOBUOY_VERSION}"
  curl -L "https://github.com/vmware-tanzu/sonobuoy/releases/download/v${SONOBUOY_VERSION}/sonobuoy_${SONOBUOY_VERSION}_darwin_amd64.tar.gz" | tar -xz -C /tmp
  sudo rm -rf /usr/local/bin/sonobuoy
  sudo mv /tmp/sonobuoy /usr/local/bin/sonobuoy

  # JK
  echo "Installing jk ${JK_VERSION}"
  curl -L "https://github.com/jkcfg/jk/releases/download/${JK_VERSION}/jk-darwin-amd64" -o /usr/local/bin/jk
  chmod +x /usr/local/bin/jk

  # eksctl
  echo "Installing eksctl"
  curl -L "https://github.com/weaveworks/eksctl/releases/download/0.32.0/eksctl_Darwin_amd64.tar.gz"  | tar -xz -C /tmp
  rm -f /usr/local/bin/eksctl
  mv /tmp/eksctl /usr/local/bin/eksctl

  # clusterctl
  echo "Installing clusterctl"
  curl -L "https://github.com/kubernetes-sigs/cluster-api/releases/download/v${CLUSTERCTL_VERSION}/clusterctl-darwin-amd64" -o /usr/local/bin/clusterctl
  chmod +x /usr/local/bin/clusterctl

  # Weave GitOps
  echo "Installing wego"
  curl -L "https://github.com/weaveworks/weave-gitops/releases/download/v${WEGO_VERSION}/wego-$(uname)-$(uname -m)" -o /usr/local/bin/wego
  chmod +x /usr/local/bin/wego

  # Ginkgo
  /usr/local/bin/go get -u github.com/onsi/ginkgo/ginkgo
  # Cobra
  GO111MODULE=on /usr/local/bin/go get -u github.com/spf13/cobra/cobra
  # Clusterlint
  /usr/local/bin/go get -u github.com/digitalocean/clusterlint/cmd/clusterlint
  # oauth2-proxy
  /usr/local/bin/go get -u github.com/oauth2-proxy/oauth2-proxy/v7


  ## Install VSCode extensions
  code --install-extension timonwong.shellcheck
  code --install-extension golang.Go
  code --install-extension ms-kubernetes-tools.vscode-kubernetes-tools
  code --install-extension MS-vsliveshare.vsliveshare-pack
  code --install-extension james-yu.latex-workshop
  code --install-extension hashicorp.terraform
  code --install-extension ban.spellright
}

main() {
  # Update Homebrew recipes
  brew update --force

  # Install all our dependencies with bundle (See Brewfile)
  brew tap homebrew/bundle
  brew bundle --no-lock
  brew bundle cleanup --force

  setup_zsh
  setup_vim
  install_dotfiles
  post_install

  brew upgrade
  brew cleanup
}

main



