## Fancy PWD display function
## The home directory (HOME) is replaced with a ~
## The last pwdmaxlen characters of the PWD are displayed
## Leading partial directory names are striped off
## /home/me/stuff    -> ~/stuff      if USER=me
## /usr/share/big_dir_name -> ../share/big_dir_name if pwdmaxlen=20
##
## Source: WOLFMAN'S color bash promt
#
#~/.bashrc
#
## ARRANGE $PWD AND STORE IT IN $NEW_PWD
bash_prompt_command() {
 # How many characters of the $PWD should be kept
 local pwdmaxlen=25

 # Indicate that there has been dir truncation
 local trunc_symbol=".."

 # Store local dir
 local dir=${PWD##*/}

 # Which length to use
 pwdmaxlen=$(( ( pwdmaxlen < ${#dir} ) ? ${#dir} : pwdmaxlen ))

 NEW_PWD=${PWD/#$HOME/\~}
 
 local pwdoffset=$(( ${#NEW_PWD} - pwdmaxlen ))

 # Generate name
 if [ ${pwdoffset} -gt "0" ]
 then
  NEW_PWD=${NEW_PWD:$pwdoffset:$pwdmaxlen}
  NEW_PWD=${trunc_symbol}/${NEW_PWD#*/}
 fi
}


## COLORIZE
bash_prompt() {
 case $TERM in
 xterm*|rxvt*)
   local TITLEBAR='\[\033]0;\u:${NEW_PWD}\007\]'
    ;;
  *)
   local TITLEBAR=""
    ;;
 esac
 local NONE="\[\033[0m\]" # unsets color to term's fg color
 
 # regular colors
 local K="\[\033[0;30m\]" # black
 local R="\[\033[0;31m\]" # red
 local G="\[\033[0;32m\]" # green
 local Y="\[\033[0;33m\]" # yellow
 local B="\[\033[0;34m\]" # blue
 local M="\[\033[0;35m\]" # magenta
 local C="\[\033[0;36m\]" # cyan
 local W="\[\033[0;37m\]" # white
 
 # emphasized (bolded) colors
 local EMK="\[\033[1;30m\]"
 local EMR="\[\033[1;31m\]"
 local EMG="\[\033[1;32m\]"
 local EMY="\[\033[1;33m\]"
 local EMB="\[\033[1;34m\]"
 local EMM="\[\033[1;35m\]"
 local EMC="\[\033[1;36m\]"
 local EMW="\[\033[1;37m\]"
 local EMO="\[\033[38;5;208m\]" # Orange bold
 local EMT="\[\033[38;5;118m\]" # Toxic green
 
 # background colors
 local BGK="\[\033[40m\]"
 local BGR="\[\033[41m\]"
 local BGG="\[\033[42m\]"
 local BGY="\[\033[43m\]"
 local BGB="\[\033[44m\]"
 local BGM="\[\033[45m\]"
 local BGC="\[\033[46m\]"
 local BGW="\[\033[47m\]"
 
 local UC=$EMW   # user's color
 [ $UID -eq "0" ] && UC=$R # root's color
 
 
 PS1="$TITLEBAR ${EMK}[${UC}\u${EMK}@${UC}\h ${EMC}\${NEW_PWD}${EMK}]${EMC}\\$ ${EMT}"
 

 # without colors: PS1="[\u@\h \${NEW_PWD}]\\$ "
 # extra backslash in front of \$ to make bash colorize the prompt

 # for terminal line coloring, leaving the rest standard
 none="$(tput sgr0)"
 trap 'echo -ne "${none}"' DEBUG
}


## Bash provides an environment variable called PROMPT_COMMAND. 
## The contents of this variable are executed as a regular Bash command 
## just before Bash displays a prompt. 
## We want it to call our own command to truncate PWD and store it in NEW_PWD
PROMPT_COMMAND=bash_prompt_command

## Call bash_promnt only once, then unset it (not needed any more)
## It will set $PS1 with colors and relative to $NEW_PWD, 
## which gets updated by $PROMT_COMMAND on behalf of the terminal
bash_prompt
unset bash_prompt
## EOF
