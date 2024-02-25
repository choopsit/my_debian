# my\_debian

personal debian xfce config (tested on 12.x "bookworm" and sid)

---------

## how to

run "install.sh" to deploy.

---------

## desktop

base package: task-xfce-desktop (+ task-desktop)

---------

## applications

*/!\ WARNING: some applications you previously installed could be uninstalled during the process if they are or depend on one of the packages listed in "config/pkg/xfce\_useless"*

### system-tools

- terminal-emulator: xfce4-terminal *(from desktop base)*
- system-monitor: htop
- virtualization supports [optional]: virt-manager, cockpit-machines

### accessories

- dock: plank
- text-editors: mousepad *(from desktop base)*, vim
- archivers: p7zip-full, file-roller
- day/night-color-temperature: redshift

### internet

- web-browser: firefox on sid|firefox-esr on bookworm, chromium [optional]
- torrent-clients [optional]: transmission-qt *(add qt5ct for better qt5-apps integration)*, deluge

### multimedia

- video-player: mpv
- music-players: quodlibet *(from desktop base)*, lollypop [optional]
- tag-editor: exfalso *(from desktop base)*
- audio-ripper/editors [optional]: sound-juicer, soundconverter, audacity
- mediacenter [optional]: kodi

### office

- office-suite: libreoffice *(from desktop base)*
- PDF-viewer: evince

### graphisme

- image-viewer: eog (eye of gnome)
- image-editors [optional]: gimp, inkscape
- 3D-editor [optional]: blender

### science [optional]

- freecad
- leocad (virtual brick CAD)
- stellarium

### games [optional]

- steam
- pcsx2 (playstation 2 emulator)
- supertuxkart
- 0ad
- pokerth
- quadrapassel (tetris-like)
- gnome-2048

---------

## personalization

### default theme

- gtk-theme: Colloid gruvbox dark - https://github.com/vinceliuice/Colloid-gtk-theme
- icon-theme: papirus 'yaru' (using papirus-folders: https://github.com/PapirusDevelopmentTeam/papirus-folders)
- cursors: WhiteSur-cursors - https://github.com/vinceliuice/WhiteSur-cursors

### more installable themes with scripts deployed in $HOME/.local/bin

#### gtk-themes

- colloid\_gtk: gruvbox/nord/teal dark: https://github.com/vinceliuice/Colloid-gtk-theme
- gruvbox\_gtk: ttps://github.com/Fausto-Korpsvart/Gruvbox-GTK-Theme
- whiteSur\_gtk: https://github.com/vinceliuice/WhiteSur-gtk-theme

#### icon-themes

- gruvbox\_icons: https://github.com/SylEleuth/gruvbox-plus-icon-pack
- kora\_icons: https://github.com/bikass/kora
- whitesur\_icons: https://github.com/vinceliuice/WhiteSur-icon-theme

#### cursors

- mcmojave\_cursors: https://github.com/vinceliuice/McMojave-cursors

---------

## Other scripts

### userlevel: $HOME/.local/bin

- pastep: set volume up/down step in percent
- linein: switch audio line in on/off
- sysinfo: combine bfetch and bdf (+ upgrade)
- statgitrepo: return state of git repos in $HOME/Work/git
- themeupragde: upgrade themes installed with supplied scripts
- tsm: simple transmission-daemon management
- backup: rsync backup (few sytem conf + $HOME important things) to /volumes/backup

### systemlevel: /usr/local/bin

- bdf: graphical view of 'df' (python alternative: pydf)
- bfetch: system informations (python alternative: pyfetch)
- netinfo: return connexions informations (actually python but may switch to bash)
- udbcreator: generate bootable USB key
