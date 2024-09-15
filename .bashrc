#
# ~/.bashrc
#

# This fuctions were taken from ohmybash repository 
# This theme is very similar to robyrussell theme.
# I make some modifications to the theme to fit my 
# personal requierements.
# theme name: vscode.theme.sh

### Preview
# ➜ dotfiles git:(master ✗) $

function _omb_prompt_git {
    command git "$@"
}

function _omb_theme_vscode_initialize {
    local userpart='`export XIT=$? \
        && [ "$XIT" -ne "0" ] && echo -n "\[\033[1;31m\]➜" || echo -n "\[\033[32m\]➜"`'
    local gitbranch='`\
        if [ "$(_omb_prompt_git config --get codespaces-theme.hide-status 2>/dev/null)" != 1 ]; then \
            export BRANCH=$(_omb_prompt_git symbolic-ref --short HEAD 2>/dev/null || _omb_prompt_git rev-parse --short HEAD 2>/dev/null); \
            if [ "${BRANCH}" != "" ]; then \
                echo -n "\[\033[0;36m\]git:(\[\033[1;31m\]${BRANCH}" \
                && if _omb_prompt_git ls-files --error-unmatch -m --directory --no-empty-directory -o --exclude-standard ":/*" > /dev/null 2>&1; then \
                        echo -n " \[\033[1;33m\]✗"; \
                fi \
                && echo -n "\[\033[0;36m\]) "; \
            fi; \
        fi`'
    local lightblue='\[\033[1;34m\]'
    local removecolor='\[\033[0m\]'
    PS1="${userpart} ${lightblue}\W ${gitbranch}${removecolor}\$ "
    unset -f _omb_theme_vscode_initialize
}

# If not running interactively, don't do anything
[[ $- != *i* ]] && return

bind "set completion-ignore-case on"

# To get this alias working you've to install exa bat and git :v
alias ls='exa --group-directories-first'
alias cat='bat'
alias gst='git status'
alias grep='grep --color=auto'

# Theme for the prompt
_omb_theme_vscode_initialize
function _omb_theme_PROMPT_COMMAND { true; }
PROMPT_DIRTRIM=${PROMPT_DIRTRIM:-4}