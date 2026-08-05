# dotfiles

Entorno de notas en Markdown: **kitty + Neovim (LazyVim) + obsidian.nvim**, con una paleta
única compartida entre el terminal y el editor. Portable a cualquier distro.

Headings con barra de color sólida, tablas con borde, sin corrector subrayando texto en
español, y transparencia real del terminal.

## Qué hay acá

```
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
./install.sh enlazar      # crea los symlinks
./install.sh comprobar    # verifica que no falte nada
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
| `nodejs` | Varios LSP de LazyVim | recomendado |

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
| `gf` | Seguir wikilink |

## Decisiones que conviene no revertir sin leer

- `obsidian.nvim` va con `frontmatter = { enabled = false }`. Por defecto reescribe el YAML
  al guardar e inyecta `id`, `aliases` y `tags`, pisando el frontmatter propio de cada nota.
- `obsidian.nvim` va con `ui = { enable = false }` porque el render lo hace
  `render-markdown.nvim`; con los dos activos se duplican checkboxes y bullets.
- `lua/config/highlights.lua` se carga desde `init.lua` **después** de `config.lazy`. Si se
  carga antes, el colorscheme pisa los colores de los headings y quedan como un tinte lavado.
- La paleta vive en `lua/config/paleta.lua` y la comparten nvim y kitty. Cambiar de
  colorscheme no cambia los headings: los define la paleta.
- El corrector ortográfico está apagado en markdown. LazyVim lo activa con `spelllang=en`, y
  sobre texto en español subraya casi cada palabra.

## Lo que no está acá

El contenido del vault: son notas, no configuración. Va en su propio repo.

`arch/dwm-config.h` está de referencia — depende de tener las fuentes de suckless en
`~/.local/src` y de recompilar. En otra distro alcanza con que `$TERMINAL` sea `kitty`.
