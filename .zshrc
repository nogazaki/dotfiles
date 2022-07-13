. ~/.shell/interactive

autoload -Uz compinit
compinit

if [ $TERM = "linux" ]; then
    autoload -Uz promptinit
    promptinit
    prompt adam2
    precmd() {
        echo
    }
else
    eval "$(starship init zsh)"
fi
zle_highlight=(default:bold,fg=white)

bindkey "^[[A" history-beginning-search-backward
bindkey "^[[B" history-beginning-search-forward

bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line

bindkey "^[[3~" vi-delete-char

# Add timestamp to history line
setopt EXTENDED_HISTORY
# Share history across multiple zsh sessions
setopt SHARE_HISTORY
# Append to the history file, rather than overwriting it
setopt APPEND_HISTORY
# Add commands as they are typed, not at shell exit
setopt INC_APPEND_HISTORY
# Do not store duplications
setopt HIST_IGNORE_DUPS
# Ignore duplicates when searching
setopt HIST_FIND_NO_DUPS
# Expire duplicates first
setopt HIST_EXPIRE_DUPS_FIRST
# Remove blank lines from history
setopt HIST_REDUCE_BLANKS
# Verify command when auto subtituted
setopt HIST_VERIFY
# Case-insensitive globbing (used in pathname expansion)
setopt NO_CASE_GLOB
# Mistype correction
setopt CORRECT
setopt CORRECT_ALL

# Autosuggest
source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh
# Syntax highlight
source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh
