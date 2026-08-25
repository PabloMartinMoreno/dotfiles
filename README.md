# dotfiles

Entorno de notas en Markdown: **zsh + kitty + Neovim (LazyVim) + obsidian.nvim**, con una
paleta única compartida entre el terminal y el editor. Portable a cualquier distro.

Headings con barra de color sólida, tablas con borde, sin corrector subrayando texto en
español, y transparencia real del terminal.

## Qué hay acá

```
home/.zprofile                    sourcea shell/profile; es quien exporta ZDOTDIR
home/.config/zsh/.zshrc           oh-my-zsh, plugins, vi-mode, keybinds, historial XDG
home/.config/zsh/.p10k.zsh        prompt powerlevel10k (salida de `p10k configure`)
home/.config/shell/profile        variables de entorno y limpieza XDG de ~
home/.config/shell/aliasrc        aliases y funciones del shell
home/.config/shell/inputrc        vi-mode para readline (bash, psql, etc.)
home/.config/shell/bm-dirs        marcadores de directorios (fuente de los atajos)
home/.config/shell/bm-files       marcadores de archivos de config
home/.config/kitty/               paleta eldritch, JetBrainsMono NF, transparencia
home/.config/nvim/                LazyVim + obsidian.nvim + render-markdown + paleta propia
home/.config/xdg-terminals.list   kitty como terminal por defecto (xdg-terminal-exec)
home/.local/bin/vault             abre el vault en kitty
arch/dwm-config.h                 específico de Arch/dwm, NO se instala solo
```

## Instalar

```sh
git clone <este-repo> ~/.dotfiles
cd ~/.dotfiles
./install.sh paquetes     # imprime el comando para tu gestor; corrélo
./install.sh fuente       # solo si tu distro no empaqueta la Nerd Font
./install.sh zsh          # clona oh-my-zsh, los plugins y powerlevel10k
./install.sh enlazar      # crea los symlinks
./install.sh comprobar    # verifica que no falte nada
chsh -s "$(command -v zsh)"
```

Después, apuntá el vault desde tu perfil de shell:

```sh
export OBSIDIAN_VAULT="$HOME/ruta/a/tu/vault"
```

Sin esa variable se asume `~/vault`.

`enlazar` respalda cualquier config existente en `~/.dotfiles-respaldo-<fecha>/` antes de
pisarla, y enlaza **archivo por archivo** en `~/.local/bin` — nunca el directorio entero,
para no tapar otros scripts que tengas ahí.

En el primer arranque de nvim, lazy.nvim instala los plugins según `lazy-lock.json`, que
está versionado: quedan las mismas versiones exactas.

`zsh` es idempotente: si los repos ya están, hace `pull --ff-only` en vez de clonar. Corrélo
otra vez cuando quieras actualizar oh-my-zsh y los plugins.

## Dependencias

| Paquete | Para qué | Obligatorio |
|---|---|---|
| `kitty` | Terminal. Resuelve los glifos Nerd Font sobre `U+FFFF`, que varios terminales no dibujan | sí |
| `neovim` ≥ 0.10 | Editor | sí |
| `ripgrep` | Búsqueda y backlinks de obsidian.nvim | sí |
| `fd` | Picker de archivos | sí |
| `git` | lazy.nvim clona los plugins | sí |
| JetBrainsMono Nerd Font | Íconos de heading y de la UI | sí |
| `lazygit` | `<leader>gg` | recomendado |
| `zsh` ≥ 5.9 | El shell | sí |
| `zoxide` | `cd` con historial | sí — el `.zshrc` lo carga si está |
| `fzf` | `Ctrl-f`, y el plugin `fzf-tab` | sí |
| `nodejs` | Varios LSP de LazyVim | recomendado |
| `yazi` | `Ctrl-o` salta al directorio elegido | opcional |
| `bat` | Plugin `zsh-bat` | opcional |

## Atajos propios

Todo cuelga de `<leader>o`:

| Tecla | Acción |
|---|---|
| `<leader>on` | Nota nueva desde plantilla |
| `<leader>oo` / `<leader>oq` | Buscar en el vault / saltar a nota |
| `<leader>ob` / `<leader>ol` | Backlinks / enlaces salientes |
| `<leader>or` | Renombrar arrastrando los enlaces |
| `<leader>om` / `<leader>oz` | Render on/off · modo zen |
| `<leader>oc` | Corre `900-meta/consultas.py` del vault, si existe |
| `<leader>os` | Corrector español+inglés on/off |
| `gf` / `<CR>` | Seguir wikilink · acción según contexto |

Solo en markdown:

| Tecla | Acción |
|---|---|
| `z1` … `z6` | Plegar al nivel de heading indicado (`zR`, `zM`, `za` nativos) |
| `]]` / `[[` | Heading siguiente / anterior (ftplugin de nvim, sin configurar) |
| `gsab` / `gsac` | Envolver en `**negrita**` / `` `código` `` |

## Decisiones que conviene no revertir sin leer

- `obsidian.nvim` va con `frontmatter = { enabled = false }`. Por defecto reescribe el YAML
  al guardar e inyecta `id`, `aliases` y `tags`, pisando el frontmatter propio de cada nota.
- `obsidian.nvim` va con `ui = { enable = false }` porque el render lo hace
  `render-markdown.nvim`; con los dos activos se duplican checkboxes y bullets.
- `lua/config/highlights.lua` se carga desde `init.lua` **después** de `config.lazy`. Si se
  carga antes, el colorscheme pisa los colores de los headings y quedan como un tinte lavado.
- La paleta vive en `lua/config/paleta.lua` y la comparten nvim y kitty. Cambiar de
  colorscheme no cambia los headings: los define la paleta.
- La config de zsh vive en `~/.config/zsh` porque `shell/profile` exporta `ZDOTDIR`. zsh
  relee `$ZDOTDIR` después de cada archivo de arranque, y `~/.zprofile` corre antes de que
  busque `.zshrc`: por eso el único archivo que queda suelto en `~` es `.zprofile`.
- oh-my-zsh y los 8 repos de plugins/tema **no** están versionados — los clona
  `install.sh zsh` a `~/.config/zsh/ohmyzsh`. El `.zshrc` los carga por ruta fija
  (`ZSH="$ZDOTDIR/ohmyzsh"`), así que el directorio tiene que llamarse así.
- `shortcutrc` y `zshnameddirrc` tampoco están: los **genera** el script `shortcuts` de LARBS
  a partir de `bm-dirs` y `bm-files`, con rutas absolutas de la máquina. Versionar la salida
  en vez de la fuente rompería en cualquier otro `$HOME`. Sin el script, el `.zshrc` los
  saltea sin quejarse.
- El prompt instantáneo de powerlevel10k tiene que quedarse arriba de todo en el `.zshrc`.
  Cualquier cosa que pida input por consola va **antes** de ese bloque, o se traba.
- El corrector ortográfico está apagado en markdown. LazyVim lo activa con `spelllang=en`, y
  sobre texto en español subraya casi cada palabra.

## Lo que no está acá

El contenido del vault: son notas, no configuración. Va en su propio repo.

`arch/dwm-config.h` está de referencia — depende de tener las fuentes de suckless en
`~/.local/src` y de recompilar. En otra distro alcanza con que `$TERMINAL` sea `kitty`.
