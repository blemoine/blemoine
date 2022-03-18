export PS1="%~ %F{cyan}$%f"
alias ls="ls -Gh"
alias ll="ls -l"
alias temperature="sudo powermetrics --samplers smc |grep -i 'temp'"

zstyle ':completion:*:*:git:*' script ~/.zsh/git-completion.bash
fpath=(~/.zsh $fpath)

autoload -Uz compinit && compinit

alias git='noglob git'
