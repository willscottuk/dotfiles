# switching by os
case ${OSTYPE} in
  darwin*)
    # export PATH=/Library/TeX/texbin:$PATH
    # coreutils. for more information, `brew info coreutils`
    if [[ -d /usr/local/opt/coreutils ]]; then
      export PATH=/usr/local/opt/coreutils/libexec/gnubin:$PATH
      export MANPATH=/usr/local/opt/coreutils/libexec/gnuman:$MANPATH
      alias ls="ls --color"
      export LSCOLORS=gxfxcxdxbxegedabagacad
    else
      alias ls="ls -GAl"
    fi
    # gnu-sed (which is not included in coreutils package). for more information, `brew info gnu-sed`
    if [[ -d /usr/local/opt/gnu-sed ]]; then
      export PATH=/usr/local/opt/gnu-sed/libexec/gnubin:$PATH
      export MANPATH=/usr/local/opt/gnu-sed/libexec/gnuman:$MANPATH
    fi
    ;;
  linux*)
    alias ls="ls -Al --color"
    export LSCOLORS=gxfxcxdxbxegedabagacad
    if [[ -d ~/.linuxbrew ]]; then
      export PATH=$HOME/.linuxbrew/bin:$PATH
    fi

    unset MAILCHECK
    ;;
esac
