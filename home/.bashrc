# Abort if the shell is non-interactive
[[ $- != *i* ]] && return

common() {
    :
    #source ~/.git-prompt.sh

    alias ls='ls --color=auto'
    if [[ "$PS1" != *chrootenv* ]]; then
        export PS1="[\u@\h:\W]\\$ "
    fi

    # Typing a path will cd to that directory
    shopt -s autocd
    # Jump back one directory (Only works once)
    alias back='cd -'

    # Commands prefixed with a space won't appear in history
    export HISTCONTROL='ignorespace'

    # Specific commands that don't appear in history
    export HISTIGNORE='clear:tclear'
    
    # Aliases
    alias clear='clear; clear'
    alias please='sudo $(fc -ln -1)'
    alias gitfiles='git ls-tree --full-tree -r HEAD'
    alias remacs='sudo -s emacs'
    alias sshpi='ssh pi@raspberrypi'
    alias rebuild='sudo nixos-rebuild switch'
    alias upgrade='sudo nixos-rebuild switch --upgrade'
    alias software='remacs /etc/nixos/software.nix'
    alias prog='remacs /etc/nixos/languages.nix'
}

laptop() {
    :
    # PATH Manipulations
    export PATH=${PATH+:$PATH:}$HOME/.local/bin
    export PYTHONPATH=${PYTHONPATH+:$PYTHONPATH:}$HOME/Scripts/Python/lib

    # Aliases
    alias tclear='clear; task list'
    alias pythondir='cd $HOME/Scripts/Python'
    alias perldir='cd $HOME/Scripts/Perl'
    alias cdir='cd $HOME/Scripts/C'
    alias cppdir='cd $HOME/Scripts/C++'
    alias numpydir='cd $HOME/Scripts/Python/numpy'
}

desktop() {
    :
    # Aliases
    alias rubydir='cd $HOME/Scripts/Ruby'
    alias railsdir='cd $HOME/Scripts/Ruby/Rails'
}

# Functions
notify() {
    "$@" && notify-send -t 0 "Command Completed: $*" || notify-send -t 0 "Command Failed: $*"
}

# Run common configuration
common

case "$HOSTNAME" in
    'laptop')
        # Run laptop specific config
        laptop;;
    'desktop')
        # Run desktop specific config
        desktop;;
    *)
        # Unknown hostname
        echo "No Config found for $HOSTNAME";;
esac

# Remove config function definitions
unset -f common
unset -f laptop
unset -f desktop
