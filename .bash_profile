# Add `~/bin` to the `$PATH`
export PATH="$HOME/bin:$PATH";

# Sources bash completions from the usual place for bash 3.2
if [ -f $(brew --prefix)/etc/bash_completion ]; then
    . $(brew --prefix)/etc/bash_completion
fi

# For bash 4+ source bash completions from here
if [ -f $(brew --prefix)/etc/profile.d/bash_completion.sh ]; then
   . $(brew --prefix)/etc/profile.d/bash_completion.sh
fi
