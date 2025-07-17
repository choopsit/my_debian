# my\_debian

personal debian xfce (tested on 12.x "bookworm" and sid)

---------

## how to

run "**install.sh**" to deploy.

*/!\ WARNING: some applications you previously installed could be uninstalled during the process if they are or depend on one of the packages listed in "config/pkg/useless"*

---------

## xfce desktop

**base package**: task-xfce-desktop + task-desktop

### applications

#### system-tools

- terminal-emulator [choice]: xfce4-terminal *(from desktop base)* or terminator or tilix
- system-monitor: htop, xfce4-taskmanager [optional], gnome-system-monitor [optional]
- system-informations [otional]: hardinfo
- disk-tools [optional]: gparted, qdirstat
- backups [optional]: deja-dup
- virtualization supports [optional]: virt-manager, cockpit-machines, gnome-boxes

#### accessories

- dock: plank [optional]
- text-editors: mousepad *(from desktop base)*, vim
- archivers: 7zip, xarchiver *(from desktop base)*
- day/night-color-temperature: redshift

#### internet

- web-browser: firefox on sid | firefox-esr on bookworm, chromium [optional]
- torrent-clients [optional]: transmission-qt *(add qt5ct/qt6ct for better qt5/qt6-apps integration)*, qbittorrent

#### multimedia

- video-player: parole *(from desktop base)*, clapper, mpv, vlc _[choose another video-player removes parole]_
- video-editor [optional]: kdenlive
- music-players: quodlibet *(from desktop base)*, lollypop [optional]
- tag-editor: exfalso *(from desktop base)*
- audio-rippers/editors [optional]: sound-juicer, soundconverter, audacity
- mediacenter [optional]: kodi
- cd/dvd-tool [optional]: brasero
- drum-machine: hydrogen

#### graphisme

- image-viewer: ristretto *(from desktop base)*, gthumb [optional - *replace ristretto*]
- image-editors [optional]: gimp, inkscape, krita
- 3D-editor [optional]: blender
- scan-manager [optional]: simple-scan

#### office

- office-suite: libreoffice *(from desktop base)*
- pdf-viewer [optional]: evince
- notes: zim
- printer-manager [optional]: system-config-printer

#### science [optional]

- freecad
- leocad (virtual brick CAD)
- stellarium
- gelemental
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

## personalization

### default theme

- **gtk-theme**: Colloid gruvbox dark - https://github.com/vinceliuice/Colloid-gtk-theme
- **icon-theme**: Gruvbox-Plus-icon-pack - https://github.com/SylEleuth/gruvbox-plus-icon-pack
- **cursors**: Colloid-cursors - https://github.com/vinceliuice/Colloid-icon-theme

### more installable themes with scripts deployed in $HOME/.local/bin

#### gtk-themes

- **colloid_gtk**: dark variants including 'gruvbox': https://github.com/vinceliuice/Colloid-gtk-theme
- **whiteSur_gtk**: https://github.com/vinceliuice/WhiteSur-gtk-theme

#### icon-themes

- **colloid_icons-cursors**: https://github.com/vinceliuice/Colloid-icon-theme
- **gruvbox_icons**: https://github.com/SylEleuth/gruvbox-plus-icon-pack
- **kora_icons**: https://github.com/bikass/kora
- **whitesur_icons**: https://github.com/vinceliuice/WhiteSur-icon-theme

#### cursors

- **mcmojave_cursors**: https://github.com/vinceliuice/McMojave-cursors
- **whitesur_cursors**: https://github.com/vinceliuice/WhiteSur-cursors

---------

## Other scripts

### userlevel: $HOME/.local/bin

- **pastep**: set volume up/down step in percent
- **linein**: switch audio line in on/off
- **sysinfo**: combine bfetch and bdf (+ upgrade)
- **statgitrepo**: return state of git repos in $HOME/Work/git
- **themeupragde**: upgrade themes installed with supplied scripts
- **tsm**: simple transmission-daemon management

### systemlevel: /usr/local/bin

- **bdf**: graphical view of 'df' (python alternative: pydf)
- **bfetch**: system informations (python alternative: pyfetch)
- **netinfo**: return connexions informations (actually python but may switch to bash)
- **udbcreator**: generate bootable USB key
