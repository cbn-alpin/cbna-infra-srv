# .bashrc
# User specific aliases and functions

export HISTTIMEFORMAT="%d/%m/%y %T "
export PS1='\u@\h:\W \$ '

# Source global definitions
if [ -f /etc/bash/bashrc ]; then
	. /etc/bash/bashrc
fi
export PS1="\[\e[31m\][\[\e[m\]\[\e[38;5;172m\]\u\[\e[m\]@\[\e[38;5;153m\]\h\[\e[m\] \[\e[38;5;214m\]\W\[\e[m\]\[\e[31m\]]\[\e[m\]\\$ "

alias rm='rm -i'
alias cp='cp -i'
alias mv='mv -i'
alias vi='vim'
alias grep='grep --color'
alias l='ls -CF'
alias la='ls -A'
alias ll='ls -alF'
alias ls='ls --color=auto'

