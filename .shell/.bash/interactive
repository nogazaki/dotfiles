. ~/.shell/interactive

# Autocorrect typos in path names when using `cd`
shopt -s cdspell;
# Checks the window size of the terminal after each command
shopt -s checkwinsize;
# Append to the Bash history file, rather than overwriting it
shopt -s histappend;
# Case-insensitive globbing (used in pathname expansion)
shopt -s nocaseglob;

if [ $TERM != "linux" ]; then
    eval "$(starship init bash)"
fi

[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion

for (( i=1; i<${#BASH_SOURCE[@]}; i++ )); do
    echo -e "Sourced ${bold}${violet}${BASH_SOURCE[${i}]}${reset}."
done
