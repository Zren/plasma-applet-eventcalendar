# Show Desktop (Win7)

https://store.kde.org/p/1100895/

A fork of the default plasmoid but removes the icon and looks like a flat thin button. Can be configured to minimize all windows instead of "peaking" at the desktop, or to run a command. Scrolling over the button changes the volume, switch desktop, or any other command.

## Screenshots

![](https://i.imgur.com/FDuCOiZ.png)
![](https://i.imgur.com/QgdTsJD.png)


## A) Install via KDE

1. Right Click Panel > Panel Options > Add Widgets
2. Get New Widgets > Download New Widgets
3. Search: Win7 Show Desktop
5. Install
6. Drag "Show Desktop (Win7)" to your panel.

## B) Install via GitHub

```
git clone https://github.com/Zren/plasma-applets.git
cd plasma-applets/org.kde.plasma.win7showdesktop
./install
```

To update, run the `./update` script. It will run a `git pull` then reinstall the applet. Please note this script will restart plasmashell (so you don't have to relog)!
