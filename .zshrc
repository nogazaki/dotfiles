# Setup prompt
case $(tty) in /dev/tty[0-9]*) p10k_file=~/.p10k.tty.zsh ;;
                            *) p10k_file=~/.p10k.zsh     ;;
esac

if [[ -f $p10k_file ]]; then
    source $p10k_file
elif which starship > /dev/null 2>&1; then
    eval "$(starship init zsh)"
fi

# Common stuffs
. ~/.shell/interactive

# Key bindings
bindkey "^[[A" history-beginning-search-backward
bindkey "^[[B" history-beginning-search-forward
bindkey "^[[H" beginning-of-line
bindkey "^[[F" end-of-line
bindkey "^[[3~" vi-delete-char

# History
HISTSIZE=32768
HISTFILE="${HOME}/.zsh_history"
SAVEHIST="${HISTSIZE}"
HISTDUP=erase
setopt append_history       # Append to the history file, rather than overwriting it
setopt share_history        # Share history across all sessions at the same time
setopt hist_reduce_blanks   # Remove blank lines from history
setopt hist_ignore_space
setopt hist_ignore_all_dups # Do not store duplications
setopt hist_ignore_dups
setopt hist_save_no_dups
setopt hist_find_no_dups    # Ignore duplicates when searching
setopt hist_verify          # Verify command when auto subtituted

# Mistype correction
unsetopt CORRECT_ALL
setopt CORRECT

# Load zinit
source "${ZINIT_HOME:-/usr/share}/zinit/zinit.zsh"

# Add zsh plugins
zinit light Aloxaf/fzf-tab
zinit light zsh-users/zsh-autosuggestions
zinit light zsh-users/zsh-completions
zinit light zsh-users/zsh-syntax-highlighting
zinit ice depth=1; zinit light romkatv/powerlevel10k

# Load completion
autoload -Uz compinit && compinit
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
