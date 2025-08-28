# ================================
# Early Exit Conditions (Performance Critical)
# ================================

# Auto-start Hyprland on TTY1
if [[ -z "$DISPLAY" && -z "$WAYLAND_DISPLAY" && "$XDG_VTNR" -eq 1 ]]; then
  exec Hyprland
fi

# ================================
# Environment Variables & PATH
# ================================

# Base PATH setup
export PATH="$HOME/.local/share/nvim/mason/bin:$PATH"
export BUN_INSTALL="$HOME/.bun"
export PATH="$BUN_INSTALL/bin:$PATH"

# ================================
# Oh My Zsh Configuration
# ================================

export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="nicoulaj"
plugins=(git)

# Oh My Zsh options (uncomment as needed)
# CASE_SENSITIVE="true"
# HYPHEN_INSENSITIVE="true"
# DISABLE_MAGIC_FUNCTIONS="true"
# DISABLE_LS_COLORS="true"
# DISABLE_AUTO_TITLE="true"
# ENABLE_CORRECTION="true"
# COMPLETION_WAITING_DOTS="true"
# DISABLE_UNTRACKED_FILES_DIRTY="true"
# HIST_STAMPS="mm/dd/yyyy"

source $ZSH/oh-my-zsh.sh

# ================================
# External Tool Initialization
# ================================

# Node Version Manager
. /usr/share/nvm/init-nvm.sh

# Development environment files
for f in ~/.devenv/env/*; do source $f; done


# Bun completions
[ -s "/home/james/.bun/_bun" ] && source "/home/james/.bun/_bun"

# ================================
# Key Bindings & ZLE
# ================================

autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search
bindkey "^[[B" down-line-or-beginning-search

# ================================
# Session Management
# ================================

# Auto-start tmux (if not in Hyprland session)
if [[ -z "$TMUX" ]]; then
  mkdir -p ~/dev && cd ~/dev
  tmux attach-session || tmux new-session
fi

# ================================
# Prompt Initialization (Last)
# ================================

eval "$(starship init zsh)"
clear
