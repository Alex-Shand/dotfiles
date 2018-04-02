# Abort if the shell is non-interactive
[[ $- != *i* ]] && return

common() {
    :
    # Stops the prompt being reset inside an FHS env nix-shell
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
    export HISTIGNORE='clear:tclear:task:poweroff'
    
    # Aliases
    alias ls='ls --color=auto'
    alias clear='clear; clear'
    alias please='sudo $(fc -ln -1)'
    alias gitfiles='git ls-tree --full-tree -r HEAD'
    alias remacs='sudo -s emacs'
    alias sshpi='ssh pi@raspberrypi'
    alias rebuild='sudo nixos-rebuild switch'
    alias upgrade='sudo nixos-rebuild switch --upgrade'
    alias software='remacs /etc/nixos/software.nix'
    alias prog='remacs /etc/nixos/languages.nix'
    alias config='remacs /etc/nixos/configuration.nix'
    alias dev='nix-shell'
    alias puresh='nix-shell --pure'

    # Runs the a sage math jupyter notebook in the supplied directiory, defaults
    # to the current directory
    sage() {
        # Passed directory or current directory if empty
        local dir=${1:-$(pwd)}
        # Run container:
        # --rm - delete container on exit
        # --name - set a name for the container (Used below)
        # -v - Map the left directory from the outside to the right on the inside
        # -w - Set the working directory
        # -p - Map the left port on the outside to the right on the inside
        docker run --rm --name sage -v "$dir":/notebooks -w /notebooks -p 8888:8888 sagemath/sagemath-jupyter &
        # Wait for a key press
        echo "Press any key to kill the container"
        read -n 1 -s
        echo "Exiting..."
        # Stop the container using the name set above
        docker stop sage 1>/dev/null 2>&1
        echo "Done"
    }

    sshfs() {
        nix-shell -p sshfs --run "sshfs $*"
    }
}

laptop() {
    :
    # PATH Manipulations
    export PATH=${PATH+:$PATH:}$HOME/.local/bin
    export PYTHONPATH=${PYTHONPATH+:$PYTHONPATH:}$HOME/Scripts/Python/lib:$HOME/Scripts/Python/test_lib
    export PERL5LIB=${PERL5LIB+:$PERL5LIB:}/perllib

    # Aliases
    alias tclear='clear; task list'
    alias pythondir='cd $HOME/Scripts/Python'
    alias perldir='cd $HOME/Scripts/Perl'
    alias cdir='cd $HOME/Scripts/C'
    alias cppdir='cd $HOME/Scripts/C++'
    alias numpydir='cd $HOME/Scripts/Python/numpy'

    # Functions
    notify() {
        "$@" && notify-send -t 0 "Command Completed: $*" || notify-send -t 0 "Command Failed: $*"
    }
}

desktop() {
    :
    # Aliases
    alias rubydir='cd $HOME/Scripts/Ruby'
    alias railsdir='cd $HOME/Scripts/Ruby/Rails'
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
