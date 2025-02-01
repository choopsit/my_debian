# my\_debian

personal debian xfce/gnome config (tested on 12.x "bookworm" and sid)

---------

## how to

run "**install.sh**" to deploy.

then choose desktop configuration to apply: xfce or gnome

*/!\ WARNING: some applications you previously installed could be uninstalled during the process if they are or depend on one of the packages listed in "config/pkg/xfce\_useless"*

---------

## xfce desktop

**base package**: task-xfce-desktop (+ task-desktop)

### applications

#### system-tools

- terminal-emulator [choice]: xfce4-terminal *(from desktop base)* or terminator
- system-monitor: htop, gnome-system-monitor [optional]
- virtualization supports [optional]: virt-manager, cockpit-machines

#### accessories

- dock: plank
- text-editors: mousepad *(from desktop base)*, vim
- archivers: 7zip, xarchiver *(from desktop base)*
- day/night-color-temperature: redshift

#### internet

- web-browser: firefox on sid | firefox-esr on bookworm, chromium [optional]
- torrent-clients [optional]: transmission-qt *(add qt5ct/qt6ct for better qt5/qt6-apps integration)*, deluge

#### multimedia

- video-player: mpv
- video-editor [optional]: kdenlive
- music-players: quodlibet *(from desktop base)*, lollypop [optional]
- tag-editor: exfalso *(from desktop base)*, easytag [optional]
- audio-rippers/editors [optional]: sound-juicer, soundconverter, audacity
- mediacenter [optional]: kodi

#### office

- office-suite: libreoffice *(from desktop base)*
- pdf-viewer [optional]: evince

#### graphisme

- image-viewer: gthumb
- image-editors [optional]: gimp, inkscape, krita
- 3D-editor [optional]: blender

#### science [optional]

- freecad
- leocad (virtual brick CAD)
- stellarium
- gelementar
- avogadro

#### games [optional]

- steam
- pcsx2 (playstation 2 emulator)
- mednaffen (multiple retro consoles emulator)
- supertuxkart
- 0ad
- pokerth
- quadrapassel (tetris-like)
- gnome-2048

---------

## gnome desktop

**base package**: task-gnome-desktop (+ task-desktop + gnome-tweaks)

### applications

#### system-tools

- terminal-emulator [choice]: gnome-terminal *(from desktop base)* or terminator
- system-monitor: htop
- virtualization supports [optional]: virt-manager, cockpit-machines

#### accessories

- text-editors: gedit *(from desktop base)*, vim
- archivers: 7zip, file-roller *(from desktop base)*
- day/night-color-temperature: redshift

#### internet

- web-browser: firefox on sid | firefox-esr on bookworm, chromium [optional]

#### multimedia

- video-player: mpv
- video-editor [optional]: kdenlive
- music-players: rhythmbox *(from desktop base)*, lollypop [optional]
- tag-editor [optional]: easytag
- audio-rippers/editors [optional]: sound-juicer, soundconverter, audacity
- mediacenter [optional]: kodi

#### office

- office-suite: libreoffice *(from desktop base)*
- pdf-viewer: evince *(from desktop base)*

#### graphisme

- image-viewer: eog (eye of gnome)
- image-editors [optional]: gimp, inkscape
- 3D-editor [optional]: blender

#### science [optional]

- freecad
- leocad (virtual brick CAD)
- stellarium

#### games [optional]

- steam
- pcsx2 (playstation 2 emulator)
- mednaffen (multiple retro consoles emulator)
- supertuxkart
- 0ad
- pokerth

---------

## personalization

### default theme

- **gtk-theme**: Colloid gruvbox dark - https://github.com/vinceliuice/Colloid-gtk-theme
- **icon-theme**: papirus 'yaru' (using papirus-folders: https://github.com/PapirusDevelopmentTeam/papirus-folders)
- **cursors**: WhiteSur-cursors - https://github.com/vinceliuice/WhiteSur-cursors

### more installable themes with scripts deployed in $HOME/.local/bin

#### gtk-themes

- **colloid_gtk**: dark variants including 'gruvbox': https://github.com/vinceliuice/Colloid-gtk-theme
- **whiteSur_gtk**: https://github.com/vinceliuice/WhiteSur-gtk-theme

#### icon-themes

- **gruvbox_icons**: https://github.com/SylEleuth/gruvbox-plus-icon-pack
- **kora_icons**: https://github.com/bikass/kora
- **whitesur_icons**: https://github.com/vinceliuice/WhiteSur-icon-theme

#### cursors

- **mcmojave_cursors**: https://github.com/vinceliuice/McMojave-cursors

---------

## Other scripts

### userlevel: $HOME/.local/bin

- **pastep**: set volume up/down step in percent
- **linein**: switch audio line in on/off
- **sysinfo**: combine bfetch and bdf (+ upgrade)
- **statgitrepo**: return state of git repos in $HOME/Work/git
- **themeupragde**: upgrade themes installed with supplied scripts
- **tsm**: simple transmission-daemon management
- **backup**: rsync backup (few sytem conf + $HOME important things) to /volumes/backup

### systemlevel: /usr/local/bin

- **bdf**: graphical view of 'df' (python alternative: pydf)
- **bfetch**: system informations (python alternative: pyfetch)
- **netinfo**: return connexions informations (actually python but may switch to bash)
- **udbcreator**: generate bootable USB key
