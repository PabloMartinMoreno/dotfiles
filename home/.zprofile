# zsh lee ~/.zprofile antes de buscar .zshrc, y vuelve a mirar $ZDOTDIR después de
# cada archivo. Por eso ZDOTDIR se exporta acá dentro, en shell/profile: es lo que
# hace que la config viva en ~/.config/zsh y no en ~.
. "${XDG_CONFIG_HOME:-$HOME/.config}/shell/profile"
