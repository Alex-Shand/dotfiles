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
    # Run emacs as root
    alias remacs='sudo -s emacs'
}

# Common configuration for machines based on configuration.nix
nix() {
    :
    # The sage jupyter kernel only seems to start when sage is run as root
    # (TODO: This is probably really bad)
    alias sage='sudo sage -n jupyter'

    ## Nix Aliases ##
    # Rebuild OS after changes to configuration.nix
    alias rebuild='sudo nixos-rebuild switch'
    # Same as above, also update channels
    alias upgrade='sudo nixos-rebuild switch --upgrade'
    alias software='remacs /etc/nixos/software.nix'
    alias prog='remacs /etc/nixos/languages.nix'
    alias config='remacs /etc/nixos/configuration.nix'
    alias dev='nix-shell'
    alias puresh='nix-shell --pure'

    #ocamlenv() {
    #    if  ! docker ps -a | grep ocaml &>/dev/null; then
    #        printf "%s" "Creating OCaml docker container..."
    #        docker create --name ocaml -it -v "$HOME/Scripts/OCaml":/workspace \
    #               -w /workspace ocaml/opam &>/dev/null
    #        echo "Done."
    #    fi
    #    docker start ocaml &>/dev/null
    #    docker exec -it ocaml bash -c \
    #           'best=$(opam switch 2>/dev/null | \
    #            perl -ne "chomp; @q=split; print qq(@q[2] )" | \
    #            perl -ne "$,=qq(\n); print grep {/^\d/} split" | \
    #            sort -V | \
    #            tail -1) && \
    #            echo $best && \
    #            opam switch $best && \
    #            eval $(opam config env) && \
    #            opam install -y ocamlfind && \
    #            ocaml util/setup.ml; \
    #            exec bash'
    #    docker stop ocaml &>/dev/null
    #}
    
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

# Centos7 virtual machine for work
#centos() {
#    :
#    export PATH=$PATH:/usr/local/buildtools
#    export PYTHONPATH=/usr/local/buildtools
#    export BUILDCONCURRENCY=`grep -c ^processor /proc/cpuinfo`
#    export SCONSFLAGS="-j${BUILDCONCURRENCY} "
#    export LOCAL_DEPENDENCY_CACHE=/scratch/alexsh/cache
#    alias emacs='_emacs'
#    export LD_LIBRARY_PATH="/usr/local/lib:$LD_LIBRARY_PATH"
#    if [[ "x$DEVTOOLSET" == "x" ]]; then
#        DEVTOOLSET="x" scl enable devtoolset-7 bash
#    fi
#}

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
