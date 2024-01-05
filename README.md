# my\_debian

personal debian xfce config (tested on boolworm and sid)

## desktop:

base package: task-xfce-desktop

## applications:

*/!\ WARNING: some pplications you previously installed could be uninstalled during the process if they are or depend on one of the packages listed in "config/pkg/xfce\_useless"*

### system-tools:

- terminal-emulator: xfce4-terminal
- virtualization-support [optional]: virt-manager
- system-monitor: htop

### accessories:

- text-editors: vim, mousepad
- archivers: p7zip-full, file-roller

### internet:

- web-browser: firefox on sid / firefox-esr on bookworm
- torrent-client [optional]: transmission-qt / deluge

### multimedia:

- video-player: mpv
- music-player: quodlibet
- Tag-editor: exfalso
- Mediacenter [optional]: kodi

### office:

- office-suite: libreoffice (from desktop base)
- PDF-viewer: evince

### graphisme:

- image-viewer: eog (eye of gnome)
- image-editor: gimp
- 3D-Editor [optional]: blender

### games [optional]:

- steam
- pcsx2 (playstation 2 emulator)
- quadrapassel (tetris-like)
- gnome-2048

---------

run "install.sh" to deploy.

---------

thinking about other Desktop Enevironments and Window Managers to provide...
