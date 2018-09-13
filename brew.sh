# Install the Xcode Command Line Developer Tools before Homebrew
declare xcode_select_installed=`xcode-select --install 2>&1 | grep "command line tools are already installed"`
if [ -z "$xcode_select_installed" ]; then
  echo "Installing Xcode command line developer tools"
  xcode-select --install
fi

if test ! $(which brew); then
  echo "Installing Homebrew"
  ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

brew update

brew upgrade
echo "Installing packages"
brew install awscli
brew install dep
brew install erlang
brew install git
brew install ghc
brew install go
brew install graphvizv
brew install htop
brew install kubectl
brew install nmap
brew install node
brew install pkg-config
brew install protobuf
brew install pyenv
brew install pyenv-virtualenv
brew install rust
brew install terraform
brew install vim --with-override-system-vi
brew install zsh zsh-completions 

brew tap homebrew/cask-fonts

brew cask upgrade
echo "Installing casks"
brew cask install 1password
brew cask install aws-vault
brew cask install docker
brew cask install font-fira-code
brew cask install google-backup-and-sync
brew cask install google-cloud-sdk
brew cask install iterm2
brew cask install java
brew cask install keybase
brew cask install minikube
brew cask install pgAdmin4
brew cask install postman
brew cask install skype
brew cask install slack
brew cask install spectacle
brew cask install typora
brew cask install virtualbox
brew cask install visual-studio-code
brew cask install zoomus
