#!/bin/sh
# Instala esta configuración en una máquina nueva.
# POSIX sh a propósito: corre en cualquier distro sin dependencias.

set -eu

REPO=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd)
ORIGEN="$REPO/home"
RESPALDO="$HOME/.dotfiles-respaldo-$(date +%Y%m%d%H%M%S)"

# Lista explícita, no un find recursivo: ~/.local/bin tiene otros scripts y
# enlazar el directorio entero los reemplazaría.
RUTAS="
.config/kitty
.config/nvim
.config/xdg-terminals.list
.config/shell/aliasrc
.config/shell/bm-dirs
.config/shell/bm-files
.config/shell/inputrc
.config/shell/profile
.config/yazi
.config/zsh/.p10k.zsh
.config/zsh/.zshrc
.local/bin/vault
.zprofile
"

# Repos que no se versionan acá: se clonan. oh-my-zsh y sus plugins son
# arboles enteros de upstream, y el .zshrc los carga por ruta fija.
OMZ="https://github.com/ohmyzsh/ohmyzsh.git"
PLUGINS="
fast-syntax-highlighting https://github.com/zdharma-continuum/fast-syntax-highlighting.git
fzf-tab https://github.com/Aloxaf/fzf-tab
you-should-use https://github.com/MichaelAquilina/zsh-you-should-use
zsh-autosuggestions https://github.com/zsh-users/zsh-autosuggestions
zsh-bat https://github.com/fdellwing/zsh-bat.git
zsh-completions https://github.com/zsh-users/zsh-completions
zsh-history-substring-search https://github.com/zsh-users/zsh-history-substring-search
"
TEMA="powerlevel10k https://github.com/romkatv/powerlevel10k.git"

enlazar() {
	for rel in $RUTAS; do
		origen="$ORIGEN/$rel"
		destino="$HOME/$rel"
		[ -e "$origen" ] || {
			echo "falta en el repo: $rel"
			continue
		}
		mkdir -p "$(dirname "$destino")"
		if [ -e "$destino" ] && [ ! -L "$destino" ]; then
			mkdir -p "$RESPALDO/$(dirname "$rel")"
			mv "$destino" "$RESPALDO/$rel"
			echo "respaldado: $rel -> $RESPALDO/$rel"
		fi
		[ -L "$destino" ] && rm "$destino"
		ln -s "$origen" "$destino"
		echo "enlazado: $rel"
	done
	chmod +x "$ORIGEN/.local/bin/vault"
	# HISTFILE apunta acá y zsh no crea el directorio: sin esto no hay historial.
	mkdir -p "${XDG_STATE_HOME:-$HOME/.local/state}/zsh"
}

# oh-my-zsh, sus plugins custom y el tema. Idempotente: si ya está, actualiza.
zsh_plugins() {
	ZSHDIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"
	clonar() {
		if [ -d "$2/.git" ]; then
			echo "actualizando: $(basename "$2")"
			git -C "$2" pull --quiet --ff-only || echo "  (pull falló, se deja como está)"
		else
			echo "clonando: $(basename "$2")"
			git clone --quiet --depth 1 "$1" "$2"
		fi
	}
	clonar "$OMZ" "$ZSHDIR/ohmyzsh"
	echo "$PLUGINS" | while read -r nombre url; do
		[ -n "$nombre" ] || continue
		clonar "$url" "$ZSHDIR/ohmyzsh/custom/plugins/$nombre"
	done
	set -- $TEMA
	clonar "$2" "$ZSHDIR/ohmyzsh/custom/themes/$1"
}

paquetes() {
	# La Nerd Font es lo único que varía de verdad entre distros.
	if command -v pacman >/dev/null; then
		echo "sudo pacman -S --needed kitty neovim ripgrep fd lazygit git nodejs python-yaml ttf-jetbrains-mono-nerd zsh zoxide fzf yazi"
	elif command -v apt >/dev/null; then
		echo "sudo apt install kitty neovim ripgrep fd-find git nodejs python3-yaml zsh zoxide fzf yazi"
		echo "# lazygit y la fuente van aparte: usar '$0 fuente'"
	elif command -v dnf >/dev/null; then
		echo "sudo dnf install kitty neovim ripgrep fd-find lazygit git nodejs python3-pyyaml zsh zoxide fzf yazi"
		echo "# la fuente va aparte: usar '$0 fuente'"
	elif command -v zypper >/dev/null; then
		echo "sudo zypper install kitty neovim ripgrep fd lazygit git nodejs python3-PyYAML zsh zoxide fzf yazi"
	else
		echo "# gestor no reconocido, ver dependencias en el README"
	fi
}

fuente() {
	if fc-list 2>/dev/null | grep -qi "JetBrainsMono Nerd Font"; then
		echo "JetBrainsMono Nerd Font ya está instalada"
		return
	fi
	dir="$HOME/.local/share/fonts/JetBrainsMono"
	echo "Bajando JetBrainsMono Nerd Font a $dir"
	mkdir -p "$dir"
	tmp=$(mktemp -d)
	curl -fsSL -o "$tmp/JetBrainsMono.zip" \
		https://github.com/ryanoasis/nerd-fonts/releases/latest/download/JetBrainsMono.zip
	unzip -q -o "$tmp/JetBrainsMono.zip" -d "$dir"
	rm -rf "$tmp"
	fc-cache -f >/dev/null
	echo "fuente instalada"
}

comprobar() {
	falta=0
	for cmd in kitty nvim rg fd lazygit git zsh zoxide fzf yazi; do
		command -v "$cmd" >/dev/null || {
			echo "falta: $cmd"
			falta=1
		}
	done
	python3 -c "import yaml" 2>/dev/null || {
		echo "falta: pyyaml (lo usa consultas.py del vault)"
		falta=1
	}
	fc-list 2>/dev/null | grep -qi "JetBrainsMono Nerd Font" || {
		echo "falta: JetBrainsMono Nerd Font"
		falta=1
	}
	[ -d "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/ohmyzsh" ] || {
		echo "falta: oh-my-zsh (usar '$0 zsh')"
		falta=1
	}
	for nombre in $(echo "$PLUGINS" | awk '{print $1}') powerlevel10k; do
		[ -d "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/ohmyzsh/custom/plugins/$nombre" ] ||
			[ -d "${XDG_CONFIG_HOME:-$HOME/.config}/zsh/ohmyzsh/custom/themes/$nombre" ] || {
			echo "falta el plugin: $nombre (usar '$0 zsh')"
			falta=1
		}
	done
	[ "$SHELL" = "$(command -v zsh)" ] || echo "aviso: \$SHELL no es zsh (usar 'chsh -s $(command -v zsh || echo /bin/zsh)')"
	[ "$falta" = 0 ] && echo "todo presente"
}

case "${1:-enlazar}" in
enlazar) enlazar ;;
zsh) zsh_plugins ;;
paquetes) paquetes ;;
fuente) fuente ;;
comprobar) comprobar ;;
*)
	echo "uso: $0 [enlazar|zsh|paquetes|fuente|comprobar]"
	exit 1
	;;
esac
