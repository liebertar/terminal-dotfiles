# Added by LM Studio CLI (lms) export PATH="$PATH:$HOME/.lmstudio/bin" # End of LM Studio CLI section
alias pycharm='open -a "PyCharm"'

# VS Code 'code' command → ~/.local/bin/code symlink 사용 (.app 직접 참조 제거 → TCC 팝업 방지)

# Color output (TERM은 ghostty/tmux가 알아서 세팅하므로 건드리지 말 것)
export CLICOLOR=1
export LSCOLORS=GxFxCxDxBxegedabagaced

# Colorful configuration
# Enable colors
autoload -U colors && colors

# Set up the prompt with more vibrant colors
PROMPT='%F{46}%n@%m%f %F{39}%~%f %F{226}$(git branch --show-current 2>/dev/null)%f
%F{51}❯%f '

# Enable syntax highlighting
source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# Enable autosuggestions
source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# Better directory listings with forced colors
alias ls='ls -G'
alias ll='ls -lG'
alias la='ls -laG'

# Git status in prompt
autoload -Uz vcs_info
precmd() { vcs_info }
zstyle ':vcs_info:git:*' formats '(%b)'

# Set pane title to repo + branch (shown in Ghostty subtitle)
function _set_pane_title() {
  local repo branch
  repo=$(git rev-parse --show-toplevel 2>/dev/null)
  if [[ -n "$repo" ]]; then
    branch=$(git symbolic-ref --short HEAD 2>/dev/null)
    print -Pn "\e]2;$(basename "$repo") [$branch]\a"
  else
    print -Pn "\e]2;%~\a"
  fi
}
# Avoid duplicate on re-source
precmd_functions=(${precmd_functions:#_set_pane_title})
precmd_functions+=(_set_pane_title)

# History settings
HISTSIZE=10000
SAVEHIST=10000
HISTFILE=~/.zsh_history
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS

# Better tab completion
autoload -Uz compinit && compinit
zstyle ':completion:*' menu select
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'

# Force color output for common commands
alias grep='grep --color=auto'
alias fgrep='fgrep --color=auto'
alias egrep='egrep --color=auto'

. "$HOME/.local/bin/env"

# Shift+Arrow text selection in zsh
# Character selection (Shift+Arrow)
shift-select-left()  { ((REGION_ACTIVE)) || zle set-mark-command; zle backward-char; }
shift-select-right() { ((REGION_ACTIVE)) || zle set-mark-command; zle forward-char; }
zle -N shift-select-left; zle -N shift-select-right
bindkey '^[[1;2D' shift-select-left
bindkey '^[[1;2C' shift-select-right

# Word selection (Shift+Cmd+Arrow — Ghostty sends custom seq)
shift-select-word-left()  { ((REGION_ACTIVE)) || zle set-mark-command; zle backward-word; }
shift-select-word-right() { ((REGION_ACTIVE)) || zle set-mark-command; zle forward-word; }
zle -N shift-select-word-left; zle -N shift-select-word-right
bindkey '^[[1;10D' shift-select-word-left
bindkey '^[[1;10C' shift-select-word-right

# Deselect on Enter/Escape
deselect-and-accept() { REGION_ACTIVE=0; zle accept-line; }
zle -N deselect-and-accept
bindkey '^M' deselect-and-accept

# OpenClaw Completion (disabled — not installed)
# source <(openclaw completion --shell zsh)

# OpenAI API Key (for Codex CLI) — 키는 ~/.config/openai/key 에 600 권한으로 분리 보관
[[ -r ~/.config/openai/key ]] && export OPENAI_API_KEY="$(<~/.config/openai/key)"
