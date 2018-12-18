# Abort if the shell is non-interactive
[[ $- != *i* ]] && return

common() {
    :
    # Stops the prompt being reset inside an FHS env nix-shell
    if [[ "$PS1" != *chrootenv* ]]; then
        export PS1="[\u@\h:\W]\\$ "
    fi

    # Don't store duplicates or commands prefixed with a space
    export HISTCONTROL='ignoreboth'

    # Specific commands that don't appear in history
    export HISTIGNORE='clear:tclear:task:poweroff:reboot'
    
    ## General Aliases ##
    # Coloured ls output
    alias ls='ls --color=auto'
    # Properly clear the terminal
    alias clear='tput reset'
    # Repeat the last command with sudo
    alias please='sudo $(fc -ln -1)'
    alias emacs='$HOME/.emacs.d/_emacs'
    # Run emacs as root
    alias remacs='sudo -s emacs'
}

# Common configuration for machines based on configuration.nix
nix() {
    :
    ## Nix Aliases ##
    # Rebuild OS after changes to configuration.nix
    alias rebuild='sudo nixos-rebuild switch'
    # Same as above, also update channels
    alias upgrade='sudo nixos-rebuild switch --upgrade'
    alias software='remacs /etc/nixos/software.nix'
    alias prog='remacs /etc/nixos/languages.nix'
    alias config='remacs /etc/nixos/configuration.nix'
    alias ns='nix-shell'
    alias ps='nix-shell --pure'
    
    sshfs() {
        nix-shell -p sshfs --run "sshfs $*"
    }
}

laptop() {
    :
    # PATH Manipulations
    export PATH=${PATH+$PATH:}$HOME/.local/bin
    export PYTHONPATH=${PYTHONPATH+$PYTHONPATH:}$HOME/Scripts/Python:$HOME/Scripts/Python/lib

    # Aliases
    alias tclear='clear; task list'

    # Functions
    notify() {
        "$@" && notify-send -t 0 "Command Completed: $*" || \
                notify-send -t 0 "Command Failed: $*"
    }
}

desktop() {
    :
}

# Run common configuration
common

case $(hostname) in
    'laptop')
        # Run laptop specific config
        nix;
        laptop;;
    'desktop')
        # Run desktop specific config
        nix;
        desktop;;
    *)
        # Unknown hostname
        echo "No Config found for $(hostname)";;
esac

# Remove config function definitions
unset -f common
unset -f nix
unset -f laptop
unset -f desktop

# Load testing config
if [[ -f ".bashrc.testing" ]]; then
    source .bashrc.testing
fi
