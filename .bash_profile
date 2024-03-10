# Ensure ~/.shell/env gets run first
. ~/.shell/env

# Prevent it from being run later, since we need to use $BASH_ENV for
# non-login non-interactive shells.
# We don't export it, as we may have a non-login non-interactive shell as
# a child.
unset BASH_ENV

. ~/.shell/login

# Specify the history file
export HISTFILE=~/.bash_history
# Increase bash history size, allow 2^15 entries (default is 500)
export HISTSIZE=32768;
export HISTSFILESIZE="${HISTSIZE}";
# Omit duplicates and commands beginning with a space from history
export HISTCONTROL=ignoreboth:erasedups;

# # Source configuration of GNU readline
# export INPUTRC=$HOME/.inputrc

# Test for interactive shell
[[ $- == *i* ]] && . ~/.shell/interactive.bash
