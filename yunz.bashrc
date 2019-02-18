#!/bin/bash
# vim: set filetype=sh:

#============================================#
#   set up LS_COLORS
#============================================#
if [ -f ~/.dircolors ]; then
    eval $(dircolors ~/.dircolors)
fi

#============================================#
#   Load local settings
#============================================#
if [ -f ~/.localsettings.bashrc ]; then
	source ~/.localsettings.bashrc
fi

#============================================#
#   Aliases for easy usage
#============================================#
alias ls='\ls --color=auto'
alias cp='\cp -i'
alias rm='\rm -i'
alias mv='\mv -i'

echocolor() {
	echo -e "\\e[1;38;5;${2:-255}m$1\\e[0m"
}

yunzBashEnv_SetColor() {
    colors=(196 46 226 69 169 39 254 129 136 184 202)
    echo ${colors[$((RANDOM%${#colors[*]}))]}
}

yunzBashEnv_HOSTNAME=(${LOCALHOST:-$HOSTNAME})
if [ -x "$(which ifconfig 2>/dev/null)" ]; then
	yunzBashEnv_HOSTNAME+=($(ifconfig | grep -o 'inet addr:\([0-9]\{1,3\}\.\)\{3\}[0-9]\{1,3\}' | \
		sed 's/^inet addr://' | head -n1))
fi

yunzBashEnv_SetPS1() {
    colors=(196 46 226 69 169 39 254 129 136 184 202)
	PS1=${PS1_PARENT_PROCESS}
	if [ $OSTYPE != cygwin ]; then
		PS1+='\e[1;38;5;${colors[$((RANDOM%${#colors[*]}))]}m'
		PS1+='${yunzBashEnv_HOSTNAME[$((yunzBashEnv_GlobalCounter%${#yunzBashEnv_HOSTNAME[*]}))]}>\e[0m '
	fi
	PS1+='\e[1;38;5;${colors[$((RANDOM%${#colors[*]}))]}m\w\e[0m\n\$'
	yunzBashEnv_GlobalCounter=$((yunzBashEnv_GlobalCounter+1))
}

yunz_make_easy() {
	local x y z
	[ -n "$MY_FRIENDLY_SERVERS" ] || return 0

	while read z 
	do
		[ -n "$z" ] || continue
		read x y <<< "$z"
		read -d '@' z <<< "$y"
		eval "export RH_$(echo $x|tr '[a-z]' '[A-Z]')='$y:/home/$z'"
		eval "alias go-$x='ssh $y'"
	done <<< "$MY_FRIENDLY_SERVERS" 
}

PROMPT_COMMAND='yunzBashEnv_SetPS1'
export TERM=xterm-256color
PS1_PARENT_PROCESS=$(read -d $'\x00' -r a < /proc/$PPID/cmdline; a="${a##*/}";
  case "$a" in (vi|vim|view|vimdiff) echo "($a) ";; esac)
#export PS1+='\e[1;38;5;$(yunzBashEnv_SetColor)m\u@\h\e[0m \e[1;38;5;$(yunzBashEnv_SetColor)m\w\e[0m\n\$'
#PS1+='\e[1;38;5;$(yunzBashEnv_SetColor)m'
#PS1+='${yunzBashEnv_HOSTNAME[$((yunzBashEnv_GlobalCounter%2))]}'
#PS1+='>\e[0m \e[1;38;5;$(yunzBashEnv_SetColor)m\w\e[0m\n\$'
#export PS1

yunz_make_easy
unset yunz_make_easy

export PATH=$PATH:$(dirname ${BASH_SOURCE[0]})
shopt -s checkjobs
