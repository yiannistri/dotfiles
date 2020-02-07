# Add `~/bin` to the `$PATH`
export PATH="$HOME/bin:$PATH";

if [ -f $(brew --prefix)/etc/bash_completion ]; then
    . $(brew --prefix)/etc/bash_completion
fi
