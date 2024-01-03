# Abort if the shell is non-interactive
[[ $- != *i* ]] && return

common() {
    # Don't store duplicates or commands prefixed with a space
    export HISTCONTROL='ignoreboth'

    # Specific commands that don't appear in history
    export HISTIGNORE='clear:tclear:task:poweroff:reboot:hibernate:suspend'

    ## General Aliases ##
    # Coloured ls output
    alias ls='ls --color=auto'
    # Properly clear the terminal
    alias clear='tput reset && printf "\e[3J"'
    # Repeat the last command with sudo
    alias please='sudo $(fc -ln -1)'
    alias emacs='$HOME/.emacs.d/_emacs'
    # Run emacs as root
    alias remacs='sudo -s emacs'
    alias hibernate='systemctl hibernate'
    alias suspend='systemctl suspend'
    # Empty a directory
    alias empty='rsync -rd --delete $(mktemp -d)/'
}

# Common configuration for machines based on configuration.nix
nix() {
    if [[ "${FHS:-0}" == 1 ]]; then
        export PS1="\e[0;36m[\u@\h:\W]\\$ \e[m"
    else
        export PS1="[\u@\h:\W]\\$ "
    fi

    ## Nix Aliases ##
    # Rebuild OS after changes to configuration.nix
    alias rebuild='sudo nixos-rebuild switch'
    # Same as above, also update channels
    alias upgrade='sudo nixos-rebuild switch --upgrade'
    alias software='remacs /etc/nixos/software.nix'
    alias prog='remacs /etc/nixos/languages.nix'
    alias config='remacs /etc/nixos/configuration.nix'
    alias vscode='remacs /etc/nixos/vscode.nix'
    alias ns='nix-shell'

    sshfs() {
        nix-shell -p sshfs --run "sshfs $*"
    }

    docker-clean() {
        docker rm $(docker ps -a -f status=exited -q)
        docker image prune
    }

    docker-image-purge() {
        docker image rm -f $(docker image list -a -q)
    }
}

laptop() {
    export PATH=${PATH+$PATH:}$HOME/.local/bin:$HOME/.cargo/bin
    export PYTHONPATH=${PYTHONPATH+$PYTHONPATH:}$HOME/Scripts/Python:$HOME/Scripts/Python/lib
    export MYPYPATH=$PYTHONPATH

    alias tclear='clear; task list'
    alias mypy='mypy_wrapper'

    notify() {
        "$@" && notify-send -t 0 "Command Completed: $*" \
                || notify-send -t 0 "Command Failed: $*"
    }

    eval $(ssh-agent) &>/dev/null;
    ssh-add ~/.ssh/github &>/dev/null;
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
