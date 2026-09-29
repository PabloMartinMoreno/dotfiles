# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.config/zsh/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# History in XDG state directory (survives cache wipes):
HISTSIZE=50000
SAVEHIST=100000
HISTFILE="${XDG_STATE_HOME:-$HOME/.local/state}/zsh/history"
setopt HIST_IGNORE_ALL_DUPS HIST_EXPIRE_DUPS_FIRST HIST_FIND_NO_DUPS \
       HIST_IGNORE_SPACE HIST_REDUCE_BLANKS HIST_VERIFY \
       SHARE_HISTORY EXTENDED_HISTORY INC_APPEND_HISTORY_TIME

# Load aliases and shortcuts if existent.
[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/shell/shortcutrc" ] && source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/shortcutrc"
[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/shell/aliasrc" ] && source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/aliasrc"
[ -f "${XDG_CONFIG_HOME:-$HOME/.config}/shell/zshnameddirrc" ] && source "${XDG_CONFIG_HOME:-$HOME/.config}/shell/zshnameddirrc"

# Use yazi to switch directories and bind it to ctrl-o
yazicd () {
    tmp="$(mktemp -uq)"
    trap 'rm -f $tmp >/dev/null 2>&1 && trap - HUP INT QUIT TERM PWR EXIT' HUP INT QUIT TERM PWR EXIT
    yazi --cwd-file="$tmp" "$@"
    if [ -f "$tmp" ]; then
        dir="$(cat "$tmp")"
        [ -d "$dir" ] && [ "$dir" != "$(pwd)" ] && cd "$dir"
    fi
}
bindkey -s '^o' '^uyazicd\n'

bindkey -s '^a' '^ubc -lq\n'

bindkey -s '^f' '^ucd "$(dirname "$(fzf)")"\n'

bindkey '^[[P' delete-char

# Edit line in vim with ctrl-e:
autoload edit-command-line; zle -N edit-command-line
bindkey '^e' edit-command-line
bindkey -M vicmd '^[[P' vi-delete-char
bindkey -M vicmd '^e' edit-command-line
bindkey -M visual '^[[P' vi-delete


# If you come from bash you might have to change your $PATH.
# export PATH=$HOME/bin:$HOME/.local/bin:/usr/local/bin:$PATH

# Path to your Oh My Zsh installation.
export ZSH="$ZDOTDIR/ohmyzsh"

# Set name of the theme to load --- if set to "random", it will
# load a random theme each time Oh My Zsh is loaded, in which case,
# to know which specific one was loaded, run: echo $RANDOM_THEME
# See https://github.com/ohmyzsh/ohmyzsh/wiki/Themes
ZSH_THEME="powerlevel10k/powerlevel10k"

# Set list of themes to pick from when loading at random
# Setting this variable when ZSH_THEME=random will cause zsh to load
# a theme from this variable instead of looking in $ZSH/themes/
# If set to an empty array, this variable will have no effect.
# ZSH_THEME_RANDOM_CANDIDATES=( "robbyrussell" "agnoster" )

# Uncomment the following line to use case-sensitive completion.
# CASE_SENSITIVE="true"

# Uncomment the following line to use hyphen-insensitive completion.
# Case-sensitive completion must be off. _ and - will be interchangeable.
# HYPHEN_INSENSITIVE="true"

# Uncomment one of the following lines to change the auto-update behavior
# zstyle ':omz:update' mode disabled  # disable automatic updates
# zstyle ':omz:update' mode auto      # update automatically without asking
# zstyle ':omz:update' mode reminder  # just remind me to update when it's time

# Uncomment the following line to change how often to auto-update (in days).
# zstyle ':omz:update' frequency 13

# Uncomment the following line if pasting URLs and other text is messed up.
# DISABLE_MAGIC_FUNCTIONS="true"

# Uncomment the following line to disable colors in ls.
# DISABLE_LS_COLORS="true"

# Uncomment the following line to disable auto-setting terminal title.
# DISABLE_AUTO_TITLE="true"

# Uncomment the following line to enable command auto-correction.
# ENABLE_CORRECTION="true"

# Uncomment the following line to display red dots whilst waiting for completion.
# You can also set it to another string to have that shown instead of the default red dots.
# e.g. COMPLETION_WAITING_DOTS="%F{yellow}waiting...%f"
# Caution: this setting can cause issues with multiline prompts in zsh < 5.7.1 (see #5765)
# COMPLETION_WAITING_DOTS="true"

# Uncomment the following line if you want to disable marking untracked files
# under VCS as dirty. This makes repository status check for large repositories
# much, much faster.
# DISABLE_UNTRACKED_FILES_DIRTY="true"

# Uncomment the following line if you want to change the command execution time
# stamp shown in the history command output.
# You can set one of the optional three formats:
# "mm/dd/yyyy"|"dd.mm.yyyy"|"yyyy-mm-dd"
# or set a custom format using the strftime function format specifications,
# see 'man strftime' for details.
# HIST_STAMPS="mm/dd/yyyy"

# Would you like to use another custom folder than $ZSH/custom?
# ZSH_CUSTOM=/path/to/new-custom-folder

# Which plugins would you like to load?
# Standard plugins can be found in $ZSH/plugins/
# Custom plugins may be added to $ZSH_CUSTOM/plugins/
# Example format: plugins=(rails git textmate ruby lighthouse)
# Add wisely, as too many plugins slow down shell startup.
plugins=(
  git
  fast-syntax-highlighting
  zsh-autosuggestions
  you-should-use
  vi-mode
  colored-man-pages
  zsh-history-substring-search
  zsh-completions
  fzf-tab
  common-aliases
)

source $ZSH/oh-my-zsh.sh

# fast-syntax-highlighting: default comment color es black,bold -> invisible
# en fondo oscuro. 242 es gris de la rampa fija xterm-256 (no lo remapea kitty).
FAST_HIGHLIGHT_STYLES[comment]='fg=242'

# j/k en vicmd: buscar por prefijo, igual que las flechas (up-line-or-beginning-
# search, que liga omz). Los widgets stock no sirven tal cual: buscan por lo que
# hay ANTES del cursor, y al salir de insert el cursor queda sobre el último
# carácter, así que "git" buscaría por "gi" y traería un gimp. Al arrancar la
# búsqueda se corre el cursor al final; en las repeticiones se restaura el
# guardado para que el prefijo no se mueva con cada match.
# Va después de omz porque su key-bindings.zsh se carga ahí.
typeset -g __vi_hist_cursor

_vi-hist-search() {
  if [[ $LASTWIDGET == _vi-hist-(up|down) ]]; then
    CURSOR=$__vi_hist_cursor
  else
    __vi_hist_cursor=${#BUFFER}
    CURSOR=$__vi_hist_cursor
  fi
  zle ".history-beginning-search-$1" && zle .end-of-line
}
_vi-hist-up()   { [[ $LBUFFER == *$'\n'* ]] && { zle .up-line-or-history; return }
                  _vi-hist-search backward }
_vi-hist-down() { [[ $RBUFFER == *$'\n'* ]] && { zle .down-line-or-history; return }
                  _vi-hist-search forward }
zle -N _vi-hist-up
zle -N _vi-hist-down
bindkey -M vicmd 'k' _vi-hist-up
bindkey -M vicmd 'j' _vi-hist-down

# Título: solo la carpeta actual, no el path completo.
# Va después de cargar omz porque termsupport.zsh lo asigna de forma directa.
# kitty muestra en la pestaña el título de VENTANA (OSC 2 = _TITLE_IDLE), no el
# de icono (OSC 1 = _TAB_TITLE_IDLE); por eso hay que cambiar los dos.
ZSH_THEME_TERM_TAB_TITLE_IDLE='%1~'
ZSH_THEME_TERM_TITLE_IDLE='%1~'

# User configuration

# export MANPATH="/usr/local/man:$MANPATH"

# You may need to manually set your language environment
# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
export EDITOR='nvim'
export VISUAL='nvim'

# Compilation flags
# export ARCHFLAGS="-arch $(uname -m)"

# Set personal aliases, overriding those provided by Oh My Zsh libs,
# plugins, and themes. Aliases can be placed here, though Oh My Zsh
# users are encouraged to define aliases within a top-level file in
# the $ZSH_CUSTOM folder, with .zsh extension. Examples:
# - $ZSH_CUSTOM/aliases.zsh
# - $ZSH_CUSTOM/macos.zsh
# For a full list of active aliases, run `alias`.
#
# Example aliases
# alias zshconfig="mate ~/.zshrc"
# alias ohmyzsh="mate ~/.oh-my-zsh"
#

# Función para cambiar la forma del cursor según el modo de Vim
function zle-keymap-select () {
    case $KEYMAP in
        vicmd) echo -ne '\e[1 q';;     # Bloque grueso en modo normal (vicmd)
        viins|main) echo -ne '\e[5 q';; # Barra delgada en modo inserción (viins)
    esac
}
zle -N zle-keymap-select

# Inicializar en el modo de inserción con cursor barra delgada
function zle-line-init() {
    zle -K viins
    echo -ne "\e[5 q"  # Barra delgada al iniciar
}
zle -N zle-line-init

# Asegurar la barra delgada antes de cada nuevo comando
function preexec() {
    echo -ne '\e[5 q'  # Barra delgada antes de ejecutar un nuevo comando
}


# To customize prompt, run `p10k configure` or edit $ZDOTDIR/.p10k.zsh.
[[ ! -f "$ZDOTDIR/.p10k.zsh" ]] || source "$ZDOTDIR/.p10k.zsh"

command -v zoxide >/dev/null && eval "$(zoxide init zsh)"

# pnpm
export PNPM_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end

# NVIDIA PRIME render offload — launch apps on discrete GPU
alias prime='__NV_PRIME_RENDER_OFFLOAD=1 __GLX_VENDOR_LIBRARY_NAME=nvidia __VK_LAYER_NV_optimus=NVIDIA_only'

# uv / rustup: lo escribe su instalador, no siempre existe.
[ -f "$HOME/.local/bin/env" ] && . "$HOME/.local/bin/env"
