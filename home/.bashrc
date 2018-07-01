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

    ocamlenv() {
        if  ! docker ps -a | grep ocaml &>/dev/null; then
            printf "%s" "Creating OCaml docker container..."
            docker create --name ocaml -it -v "$HOME/Scripts/OCaml":/workspace \
                   -w /workspace ocaml/opam &>/dev/null
            echo "Done."
        fi
        docker start ocaml &>/dev/null
        docker exec -it ocaml bash -c \
               'best=$(opam switch 2>/dev/null | \
                perl -ne "chomp; @q=split; print qq(@q[2] )" | \
                perl -ne "$,=qq(\n); print grep {/^\d/} split" | \
                sort -V | \
                tail -2 | \
                head -1) && \
                opam switch $best && \
                eval $(opam config env) && \
                opam install -y ocamlfind && \
                ocaml util/setup.ml; \
                exec bash'
        docker stop ocaml &>/dev/null
    }
    
    sshfs() {
        nix-shell -p sshfs --run "sshfs $*"
    }

    monodevelop() {
        nix-shell -p monodevelop --run "monodevelop $*"
    }
}

laptop() {
    :
    # PATH Manipulations
    export PATH=${PATH+:$PATH:}$HOME/.local/bin
    export PYTHONPATH=${PYTHONPATH+:$PYTHONPATH:}$HOME/Scripts/Python:$HOME/Scripts/Python/lib
    export PERL5LIB=${PERL5LIB+:$PERL5LIB:}/perllib

    # Aliases
    alias tclear='clear; task list'
    alias pythondir='cd $HOME/Scripts/Python'
    alias perldir='cd $HOME/Scripts/Perl'
    alias cdir='cd $HOME/Scripts/C'
    alias cppdir='cd $HOME/Scripts/C++'
    alias numpydir='cd $HOME/Scripts/Python/numpy'
    alias ocamldir='cd $HOME/Scripts/OCaml/; nix-shell'
    alias android-emulator='$HOME/Scripts/Android_Emulator/emulator'
    alias cinterp='ccomp -interp'

    # Functions
    notify() {
        "$@" && notify-send -t 0 "Command Completed: $*" || \
                notify-send -t 0 "Command Failed: $*"
    }

    ccomp() {
        local dir=$(pwd)
        if ! docker image list | \
                cut -d ' ' -f 1 | \
                grep 'local/compcert' &>/dev/null; then
            echo "Need to compile CompCert..."
            select resp in y n; do
                case $resp in
                    n) return 0;;
                    *) break;;
                esac
            done
            cd "$HOME/Scripts/Docker/CompCert"
            docker build -t local/compcert .
            cd "$dir"
        fi
        # Run container:
        # --rm - delete container on exit
        # -v - Map the left directory from the outside to the right on the inside
        # -w - Set the working directory
        docker run --rm -v "$dir":/src -w /src local/compcert ccomp "$@"
    }
}

desktop() {
    :
    # Aliases
    alias rubydir='cd $HOME/Scripts/Ruby'
    alias railsdir='cd $HOME/Scripts/Ruby/Rails'
}

# Centos7 virtual machine for work
centos() {
    :
    export PATH=$PATH:/usr/local/buildtools
    export PYTHONPATH=/usr/local/buildtools
    export BUILDCONCURRENCY=`grep -c ^processor /proc/cpuinfo`
    export SCONSFLAGS="-j${BUILDCONCURRENCY} "
    export LOCAL_DEPENDENCY_CACHE=/scratch/alexsh/cache
    echo "Called";
    if [[ "x$DEVTOOLSET" == "x" ]]; then
        DEVTOOLSET="x" scl enable devtoolset-7 bash
    fi
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
    'centos')
        centos;;
    *)
        # Unknown hostname
        echo "No Config found for $(hostname)";;
esac

# Remove config function definitions
unset -f common
unset -f nix
unset -f laptop
unset -f desktop
unset -f centos 
