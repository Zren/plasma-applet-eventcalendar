# Audio Volume (Win7 Mixer)

https://www.kde-look.org/p/1100894/

A fork of the [default volume plasmoid](https://github.com/KDE/plasma-pa/tree/Plasma/5.5/applet) with a Windows 7 theme (vertical sliders).

* v11+ requires KDE 5.7
* v2 Tested on KDE 5.5 and 5.6


## Screenshot

![](https://i.imgur.com/6s1ZWl7.png)


## A) Install via KDE

1. Right Click Panel > Panel Options > Add Widgets
2. Get New Widgets > Download New Widgets
3. Search: Win7 Volume Mixer
5. Install
6. After installing, System Tray Settings > Extra Items > Uncheck "Audio Volume". This will hide the default audio widget.
7. Drag "Audio Volume (Win7)" to your panel.

## B) Install via GitHub

```
git clone https://github.com/Zren/plasma-applets.git
cd plasma-applets/org.kde.plasma.volumewin7mixer
./install
```

To update, run the `./update` script. It will run a `git pull` then reinstall the applet. Please note this script will restart plasmashell (so you don't have to relog)!

## C) Install via Package Manager

Some awesome users seemed to have packaged this applet under plasma5-applets-eventcalendar.

* Arch: (Out of date!) https://aur.archlinux.org/packages/plasma5-applets-volumewin7mixer/
* Chakra: https://chakralinux.org/ccr/packages.php?ID=7763
