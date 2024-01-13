# my\_debian

personal debian xfce config (tested on 12.x "bookworm" and sid)

---------

## desktop

base package: task-xfce-desktop (+ task-desktop)

---------

## applications

*/!\ WARNING: some applications you previously installed could be uninstalled during the process if they are or depend on one of the packages listed in "config/pkg/xfce\_useless"*

### system-tools

- terminal-emulator: xfce4-terminal
- system-monitor: htop
- virtualization support [optional]: virt-manager

### accessories

- text-editors: vim, mousepad
- archivers: p7zip-full, file-roller

### internet

- web-browser: firefox on sid / firefox-esr on bookworm
- torrent-client [optional]: transmission-qt / deluge

### multimedia

- video-player: mpv
- music-player: quodlibet
- tag-editor: exfalso
- mediacenter [optional]: kodi

### office

- office-suite: libreoffice (from desktop base)
- PDF-viewer: evince

### graphisme

- image-viewer: eog (eye of gnome)
- image-editor: gimp
- 3D-editor [optional]: blender

### games [optional]

- steam
- pcsx2 (playstation 2 emulator)
- quadrapassel (tetris-like)
- gnome-2048

---------

## how to

run "install.sh" to deploy.

---------

## Personalisation

### Default theme

- gtk-theme: Colloid gruvbox dark - https://github.com/vinceliuice/Colloid-gtk-theme
- icon-theme: papirus 'yaru'
- cursors: adwaita

### Installable themes with scripts deployed in $HOME/.local/bin


