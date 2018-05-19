#!/usr/bin/env bash

set -eu

opam-install() {
    opam install -y "$@" || true
}

opam-depext() {
    opam depext -y "$@" || true
}

opam update

opam-install depext

opam-depext \
    conf-gmp.1 \
    conf-zlib.1

opam-install \
    camlp4 \
    ocamlfind \
    core \
    async \
    yojson \
    core_extended \
    core_bench \
    cryptokit \
    ppx_deriving \
    menhir

if ! cat ~/.ocamlinit | grep "topfind" &>/dev/null; then
echo -e \
     "#use \"topfind\";;\n#thread;;\n#camlp4o;;\n#require \"core.top\";;\n#require \"core.syntax\";;\nopen Core" >> ~/.ocamlinit
fi
