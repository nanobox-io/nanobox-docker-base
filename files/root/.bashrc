if [ "$PS1" ]; then
  shopt -s checkwinsize cdspell extglob histappend
  alias ll='ls -lF'
  alias ls='ls --color=auto'
  HISTCONTROL=ignoreboth
  HISTIGNORE="[bf]g:exit:quit"
  RED="\[$(tput setaf 1)\]"
  YELLOW="\[$(tput setaf 3)\]"
  BLUE="\[$(tput setaf 6)\]"
  RESET="\[$(tput sgr0)\]"
  PS1="${BLUE}\u@\H${RESET}${RED}:${RESET}${YELLOW}\w ${RESET}${RED}\\$ ${RESET}"
  PS2="${RED}> ${RESET}"
fi

export PATH=$PATH:/opt/gonano/sbin:/opt/gonano/bin:/data/sbin:/data/bin
