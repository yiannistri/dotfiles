# Add `~/bin` to the `$PATH`
export PATH="$HOME/bin:$PATH";

# Sources bash completions from the usual place for bash 3.2
if [ -f $(brew --prefix)/etc/bash_completion ]; then
    . $(brew --prefix)/etc/bash_completion
fi

# Add this to enable completion for brew packages
# installed in $(brew --prefix)/etc/bash_completion.d
BASH_COMPLETION_COMPAT_DIR="$(brew --prefix)/etc/bash_completion.d"
# For bash 4.1+ use this
if [ -f $(brew --prefix)/etc/profile.d/bash_completion.sh ]; then
   . $(brew --prefix)/etc/profile.d/bash_completion.sh
fi
