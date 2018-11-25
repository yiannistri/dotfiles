# Install the Xcode Command Line Developer Tools before Homebrew
declare xcode_select_installed=`xcode-select --install 2>&1 | grep "command line tools are already installed"`
if [ -z "$xcode_select_installed" ]; then
  echo "Installing Xcode command line developer tools"
  xcode-select --install
fi
