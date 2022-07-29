# Ensure ~/.bash/env gets run first
. ~/.bash/env

# Prevent it from being run later, since we need to use $BASH_ENV for
# non-login non-interactive shells.
# We don't export it, as we may have a non-login non-interactive shell as
# a child.
unset BASH_ENV

. ~/.shell/.bash/login

# Test for interactive shell
[[ $- == *i* ]] && . ~/.shell/.bash/interactive
