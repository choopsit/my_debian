# my\_debian

personal debian xfce config (tested on 12.x "bookworm" and sid)

---------

## desktop

base package: task-xfce-desktop (+ task-desktop)

---------

## applications

*/!\ WARNING: some applications you previously installed could be uninstalled during the process if they are or depend on one of the packages listed in "config/pkg/xfce\_useless"*

### system-tools

- terminal-emulator: xfce4-terminal *(from desktop base)*
- system-monitor: htop
- virtualization support [optional]: virt-manager

### accessories

- dock: plank
- text-editors: mousepad *(from desktop base)*, vim
- archivers: p7zip-full, file-roller
- day/night-color-temperature: redshift

### internet

- web-browser: firefox on sid / firefox-esr on bookworm
- torrent-client [optional]: transmission-qt *(add qt5ct for better qt5-apps integration)*

### multimedia

- video-player: mpv
- music-player: quodlibet *(from desktop base)*
- tag-editor: exfalso *(from desktop base)*
- mediacenter [optional]: kodi

### office

- office-suite: libreoffice *(from desktop base)*
- PDF-viewer: evince

### graphisme

- image-viewer: eog (eye of gnome)
- image-editor: gimp
- 3D-editor [optional]: blender

### science

- freecad [otional]
- stellarium [optional]

### games [optional]

- steam
- pcsx2 (playstation 2 emulator)
- supertuxkart
- pokerth
- quadrapassel (tetris-like)
- gnome-2048

---------

## how to

run "install.sh" to deploy.

---------

## personalization

### default theme

- gtk-theme: Colloid gruvbox dark - https://github.com/vinceliuice/Colloid-gtk-theme
- icon-theme: papirus 'yaru' (using papirus-folders: https://github.com/PapirusDevelopmentTeam/papirus-folders)
- cursors: adwaita

### installable themes with scripts deployed in $HOME/.local/bin

#### gtk-themes

- Colloid-gtk-theme gruvbox/nord/teal dark: https://github.com/vinceliuice/Colloid-gtk-theme
- Gruvbox-GTK-Theme: ttps://github.com/Fausto-Korpsvart/Gruvbox-GTK-Theme
- WhiteSur-gtk-theme: https://github.com/vinceliuice/WhiteSur-gtk-theme

#### icon-themes

- Gruvbox-plus-icon-pack: https://github.com/SylEleuth/gruvbox-plus-icon-pack
- Kora-icon-theme: https://github.com/bikass/kora
- WhiteSur-icon-theme: https://github.com/vinceliuice/WhiteSur-icon-theme

#### cursors

- McMojave-cursors: https://github.com/vinceliuice/McMojave-cursors
- WhiteSur-cursors: https://github.com/vinceliuice/WhiteSur-cursors
