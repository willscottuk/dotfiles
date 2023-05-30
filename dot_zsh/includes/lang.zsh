# ocaml
if [ -d $HOME/.opam ]; then
    . $HOME/.opam/opam-init/init.zsh >/dev/null 2>&1 || true
fi

# rust
if [ -d $HOME/.cargo ]; then
    export PATH=$HOME/.cargo/bin:$PATH
fi

# asdf
if [ -d $HOME/.asdf ]; then
    local plugins="$HOME/.asdf/plugins"
    # java
    if [ -d $plugins/java ]; then
        . $plugins/java/set-java-home.zsh
    fi
fi
