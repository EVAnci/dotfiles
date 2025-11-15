# Lines configured by zsh-newuser-install
HISTFILE=~/.config/zsh/histfile
HISTSIZE=1000
SAVEHIST=1000
setopt nomatch
bindkey -v
# End of lines configured by zsh-newuser-install
autoload -Uz compinit promptinit vcs_info
compinit

# ==========================================
#  Tema minimalista estilo Oh-My-Bash
#  Zsh puro — sin frameworks, sin plugins
# ==========================================

autoload -Uz vcs_info
setopt prompt_subst

# --- Colores ANSI
_BOLD_GRAY="%F{244}"       # Gris tenue
_BOLD_TEAL="%F{45}"        # Verde azulado (teal)
_BOLD_BROWN="%F{1}"       # Marrón/ámbar
_BOLD_GREEN="%F{2}"        # Verde fuerte
_BOLD_NAVY="%F{12}"        # Azul oscuro
_WHITE="%F{255}"
_RESET="%f"

# --- Configuración de Git (rama y estado)
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:git:*' check-for-changes true
zstyle ':vcs_info:git:*' stagedstr " ${_BOLD_BROWN}✗${_RESET}"
zstyle ':vcs_info:git:*' unstagedstr " ${_BOLD_BROWN}✗${_RESET}"
zstyle ':vcs_info:git:*' formats "${_BOLD_GREEN}±|%b${_RESET}%u${_BOLD_GREEN}|${_RESET}"
zstyle ':vcs_info:git:*' actionformats "${_BOLD_GREEN}±|%b|%a${_RESET}"

# --- Función reloj
clock_prompt() {
  print -n "${_BOLD_NAVY}%D{%H:%M:%S}${_RESET} "
}

# --- Entorno virtual de Python o Conda
virtualenv_prompt() {
  if [[ -n "$VIRTUAL_ENV" ]]; then
    print -n "${_WHITE}(${_BOLD_GREEN}${${VIRTUAL_ENV:t}}${_WHITE})${_RESET} "
  elif [[ -n "$CONDA_DEFAULT_ENV" ]]; then
    print -n "${_WHITE}(${_BOLD_GREEN}${CONDA_DEFAULT_ENV}${_WHITE})${_RESET} "
  fi
}

# --- Mostrar estado de salida
ret_status() {
  local rc=$?
  if [[ $rc -eq 0 ]]; then
    print -n "${_BOLD_GREEN}→${_RESET} "
  else
    print -n "${_BOLD_BROWN}→${_RESET} "
  fi
}

# --- Actualizar información antes de mostrar el prompt
precmd() { vcs_info }

# --- Guardar historial automáticamente
preexec() { print -s "$1" }

# --- Prompt final
# See: https://zsh.sourceforge.io/Doc/Release/Prompt-Expansion.html#Shell-state
PROMPT='$(clock_prompt)$(virtualenv_prompt)${_BOLD_GRAY}%n@%m${_RESET} ${_BOLD_TEAL}%1~${_RESET} ${vcs_info_msg_0_}$(ret_status)'

# ==========================================
#  Fin del tema
# ==========================================

# Historial incremental según lo escrito
autoload -Uz up-line-or-beginning-search down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey '^[[A' up-line-or-beginning-search   # Flecha arriba
bindkey '^[[B' down-line-or-beginning-search # Flecha abajo

# Classic reverse search <Ctrl>+R 
bindkey '^R' history-incremental-search-backward

# Case insensitive
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'

# Mejoras de autocompletado
zstyle ':completion:*' menu select
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"

# Enables autocompletion in sudo commands
zstyle ':completion::complete:*' gain-privileges 1

alias cat=bat
alias ls='exa --group-directories-first'
alias gst='git status'

resumen="/home/elio/Documentos/UM/2do/Calculo IV/Resumen/"

stophdd() {
  for hdd in {"/dev/sdb","/dev/sdc"} ; do 
    echo "[+] Power down signal to $hdd"
    sudo hdparm -Y $hdd
  done
  unset hdd
}
