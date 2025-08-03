#
# ~/.bashrc
#

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

alias ls='ls --color=auto'
alias grep='grep --color=auto'
alias U='sudo pacman -Syu' 
alias I='sudo pacman -S' 
alias ll='ls -la' 
alias Yi='sudo yay -S'
alias get_idf='. $HOME/esp/esp-idf/export.sh'
alias get_py='source $HOME/Py_Main/myenv/bin/activate'
alias vimpy='source $HOME/Py_Main/myenv/bin/activate && nvim Py_Main'
alias vimesp='. $HOME/esp/esp-idf/export.sh && nvim'
export EDITOR=nvim
#PS1='[\u@\h \W]\$ '
PS1='\[\e[38;5;250m\][\u@\h \W]  󰣇   \[\e[0m\] '
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
eval "$(pyenv init --path)"
