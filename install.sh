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
.local/bin/vault
"

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
}

paquetes() {
	# La Nerd Font es lo único que varía de verdad entre distros.
	if command -v pacman >/dev/null; then
		echo "sudo pacman -S --needed kitty neovim ripgrep fd lazygit git nodejs python-yaml ttf-jetbrains-mono-nerd"
	elif command -v apt >/dev/null; then
		echo "sudo apt install kitty neovim ripgrep fd-find git nodejs python3-yaml"
		echo "# lazygit y la fuente van aparte: usar '$0 fuente'"
	elif command -v dnf >/dev/null; then
		echo "sudo dnf install kitty neovim ripgrep fd-find lazygit git nodejs python3-pyyaml"
		echo "# la fuente va aparte: usar '$0 fuente'"
	elif command -v zypper >/dev/null; then
		echo "sudo zypper install kitty neovim ripgrep fd lazygit git nodejs python3-PyYAML"
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
	for cmd in kitty nvim rg fd lazygit git; do
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
	[ "$falta" = 0 ] && echo "todo presente"
}

case "${1:-enlazar}" in
enlazar) enlazar ;;
paquetes) paquetes ;;
fuente) fuente ;;
comprobar) comprobar ;;
*)
	echo "uso: $0 [enlazar|paquetes|fuente|comprobar]"
	exit 1
	;;
esac
