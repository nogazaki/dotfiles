# This file gets run in two cases:
# 1. non-login interactive shell
# 2. remote shell (over ssh or similar)

# #2 happens when you run "ssh user@host bash" explicitly.
# in this case, /etc/bash.bashrc has not been previous executed (unlike #1).
# Wwe assume that #2 is a recovery mode, so we don't want to do much

. ~/.shell/.bash/env

# Test for interactive shell
[[ $- == *i* ]] && . ~/.shell/.bash/interactive
