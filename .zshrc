# Path to your oh-my-zsh installation.
export EDITOR="lvim"
export STARSHIP_CONFIG="/home/plof/.starship.toml"
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
autoload -U colors && colors
alias ls="ls --color=auto" 
alias cat="bat" 
alias diff='diff --color'
alias lf="lfrun"
alias grep="grep --color "
alias record_screen="ffmpeg -video_size 1024x768 -framerate 25 -f x11grab -i :0.0+100,200 output.mp4"
alias mpvyt='yt-dlp -o - $(parcellite -p) | mpv -'
export PATH=/home/plof/.local/bin:$PATH
export PATH=/home/plof/.cargo/bin:$PATH
export NUMCPUS=`grep -c '^processor' /proc/cpuinfo`
export MAKEFLAGS="-j$NUMCPUS"
export RUSTC_WRAPPER=/usr/bin/sccache

# Basic auto/tab complete:
autoload -U compinit
zstyle ':completion:*' menu select
zmodload zsh/complist
compinit
_comp_options+=(globdots)		# Include hidden files.

HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.cache/zsh/history

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
COMPLETION_WAITING_DOTS="%F{yellow}...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"
zstyle ':completion:*' matcher-list '' 'm:{a-zA-Z}={A-Za-z}' 'r:|[._-]=* r:|=*' 'l:|=* r:|=*'

#eval "$(dircolors)"
export LS_COLORS='*.go=01;44:*.rs=01;43'
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}


#&&&&&&&&&&&&&&&&& VI-MODE &&&&&&&&&&&&&&&&&&&&&&&&&&
#plugins=(vi-mode)
#bindkey -v
#export KEYTIMEOUT=1
#
#function zle-keymap-select {
#  if [[ ${KEYMAP} == vicmd ]] ||
#     [[ $1 = 'block' ]]; then
#    echo -ne '\e[1 q'
#  elif [[ ${KEYMAP} == main ]] ||
#       [[ ${KEYMAP} == viins ]] ||
#       [[ ${KEYMAP} = '' ]] ||
#       [[ $1 = 'beam' ]]; then
#    echo -ne '\e[5 q'
#  fi
#}
#zle -N zle-keymap-select
#zle-line-init() {
#    zle -K viins # initiate `vi insert` as keymap (can be removed if `bindkey -V` has been set elsewhere)
#    echo -ne "\e[5 q"
#}
#zle -N zle-line-init
#echo -ne '\e[5 q' # Use beam shape cursor on startup.
#preexec() { echo -ne '\e[5 q' ;} # Use beam shape cursor for each new prompt.

#&&&&&&&&&&&&&&&&& SWITCH DIRS &&&&&&&&&&&&&&&&&&&&&&&&&&
#ctr-o
lfcd () {
    tmp="$(mktemp)"
    lf -last-dir-path="$tmp" "$@"
    if [ -f "$tmp" ]; then
        dir="$(cat "$tmp")"
        rm -f "$tmp"
        [ -d "$dir" ] && [ "$dir" != "$(pwd)" ] && cd "$dir"
    fi
}
bindkey -s '^o' 'lfcd\n'

#&&&&&&&&&&&&&&&&& Edit Line &&&&&&&&&&&&&&&&&&&&&&&&&&
autoload edit-command-line; zle -N edit-command-line
bindkey  '^e' edit-command-line

#&&&&&&&&&&&&&&&&& ALIAS &&&&&&&&&&&&&&&&&&&&&&&&&&
# Set personal aliases, overriding those provided by oh-my-zsh libs,
# plugins, and themes. Aliases can be placed here, though oh-my-zsh
# users are encouraged to define aliases within the ZSH_CUSTOM folder.
# For a full list of active aliases, run `alias`.
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
#
#
alias ytdl="youtube-dl"
alias ytdl-m="youtube-dl -x --audio-format mp3 "

alias push="git push -u origin main"
#
alias tk="cat githubTokem | wl-copy && echo Copiado!"

alias push="tk && git push"

alias v=$EDITOR

alias gca='git add -A; git commit -m'

#alias ls='ls -a'

alias gc='git commit -m'

alias ga='git add'

alias gu='git add -u'

alias gs='git status'

alias gr='git restore'

alias gd='git diff'

alias pac='sudo pacman'

alias grodoc='f(){ groff -ms "$1" -T pdf >> "$2"}'

alias anaconda_init='source /opt/anaconda/bin/activate root'

alias anaconda_exit='source /opt/anaconda/bin/deactivate root'

alias vmrss='f() { while true; do /bin/cat /proc/$1/status | grep "VmRSS"; sleep 1; done};f'

source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
#[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

##//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#alias ide='tmux split-window -h -p 30 ; tmux split-window -v -p 75 ; tmux last-pane ; nvim'
#
#function killAllUnnameTmuxSession() {
#  echo "\n👉 kill all unname tmux session"
#  cd /tmp/
#  tmux ls | awk '{print $1}' | grep -o '[0-9]\+' >/tmp/killAllUnnameTmuxSessionOutput.sh
#  sed -i 's/^/tmux kill-session -t /' killAllUnnameTmuxSessionOutput.sh
#  chmod +x killAllUnnameTmuxSessionOutput.sh
#  ./killAllUnnameTmuxSessionOutput.sh
#  cd -
#  tmux ls
#}
#
#function killAllUnnameTmuxSessionNoMessage() {
#  cd /tmp/
#  tmux ls | awk '{print $1}' | grep -o '[0-9]\+' >/tmp/killAllUnnameTmuxSessionOutput.sh
#  sed -i 's/^/tmux kill-session -t /' killAllUnnameTmuxSessionOutput.sh
#  chmod +x killAllUnnameTmuxSessionOutput.sh
#  ./killAllUnnameTmuxSessionOutput.sh
#  cd -
#}
#
#alias clear='killAllUnnameTmuxSessionNoMessage ; clear -x'
#alias cler='clear'
#alias clea='clear'
#alias cl='clear'
#
#function tmuxSessionSwitch() {
#  local session
#  session=$(tmux list-sessions -F "#{session_name}" | fzfDown)
#  tmux switch-client -t "$session"
#}
#alias af='tmuxSessionSwitch'
#source /usr/share/zsh/plugins/zsh-vi-mode/zsh-vi-mode.plugin.zsh

eval "$(starship init zsh)"

# opam configuration
[[ ! -r /home/plof/.opam/opam-init/init.zsh ]] || source /home/plof/.opam/opam-init/init.zsh  > /dev/null 2> /dev/null
export MODULAR_HOME="/home/plof/.modular"
export PATH=$PATH:$HOME/.local/bin
export PATH="/home/plof/.local/share/solana/install/active_release/bin:$PATH"
#export PATH="/home/plof/.modular/pkg/packages.modular.com_mojo/bin:$PATH"
function sxiveh {
	case $@ in
		http*://*) curl -o sxivimage -s "$@" ; sxiv sxivimage ; rm sxivimage;;
		*) sxiv $@;;
	esac
}

export PYENV_ROOT="$HOME/.pyenv"
[[ -d $PYENV_ROOT/bin ]] && export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init -)"



export LD_LIBRARY_PATH="$(rustc --print sysroot)/lib:$LD_LIBRARY_PATH"
