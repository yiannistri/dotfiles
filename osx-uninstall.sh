#!/bin/sh

echo "Cleaning up your Mac..."

brew cask uninstall --force $(brew bundle list --casks)

# brew uninstall --force $(brew bundle list --brews)
