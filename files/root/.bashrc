if [ "$PS1" ]; then
  shopt -s checkwinsize cdspell extglob histappend
  alias ll='ls -lF'
  alias ls='ls --color=auto'
  HISTCONTROL=ignoreboth
  HISTIGNORE="[bf]g:exit:quit"
  RED="\[$(tput setaf 1)\]"
  GREEN="\[$(tput setaf 2)\]"
  RESET="\[$(tput sgr0)\]"
  PS1="${GREEN}\w ${RESET}${RED}$ ${RESET}"
fi

export PATH=$PATH:/opt/gonano/sbin:/opt/gonano/bin:/data/sbin:/data/bin
