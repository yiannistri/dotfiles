#!/bin/sh

echo "Setting up your Mac..."

# Check for Homebrew and install if we don't have it
if test ! $(which brew); then
  /usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
fi

# Update Homebrew recipes
brew update

# Install all our dependencies with bundle (See Brewfile)
brew tap homebrew/bundle
brew bundle

# Make ZSH the default shell environment
chsh -s $(which zsh)

## Install oh-my-zsh
if [ ! -d "$HOME/.oh-my-zsh" ]; then
  curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh | sh
fi

## Install dotfiles
for file in $(find $PWD -type f -maxdepth 1 -name ".*" -not -name ".git"); do
    filename=$(basename $file);
    target="$HOME/$filename";
    echo "Linking $file to $target";
    ln -sf $file $target;
done;

## Install VSCode settings
echo "Linking $PWD/VSCode/settings.json to $HOME/Library/Application\ Support/Code/User/settings.json"
ln -sf $PWD/VSCode/settings.json $HOME/Library/Application\ Support/Code/User/settings.json

brew upgrade
brew cleanup
