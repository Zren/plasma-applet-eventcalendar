# Example plasmoid

This folder is useful for quickly writing a new plasmoid.

* Note that parent folder must match the `X-KDE-PluginInfo-Name` in the file `package/metadata.desktop` for the build/install/reinstall/run scripts to work (Someday I might rewrite those scripts to `kreadconfig`).
* Do *not* run the `install`/`reinstall` scripts with sudo or the plasmoid will be placed in `/usr/share/` instead of your home directory.

## Locations

* `/usr/share/plasma/plasmoids/`  
  Where KDE's default plasmoids are stored.
* `~/.local/share/plasma/plasmoids/`  
  Where downloaded plasmoids are stored. It's also where this example plasoid will be installed to.

## Other Examples Repositories

Note that official KDE software is only mirrored on github, but github is much better for navigating the codebase.

* https://github.com/KDE/plasma-desktop/tree/master/applets
* https://github.com/KDE/plasma-workspace/blob/master/applets
* https://github.com/KDE/kdeplasma-addons/tree/master/applets
* https://github.com/KDE/plasma-pa/tree/master/applet
* https://github.com/KDE/plasma-nm/tree/master/applet
* https://github.com/kotelnik/plasma-applet-weather-widget
* https://github.com/kotelnik/plasma-applet-redshift-control


## Documentation

* [QML documentation](http://doc.qt.io/qt-5/qtqml-syntax-basics.html)
* plasma-framework (PlasmaCore, PlasmaComponents, etc) API Documentation  
	http://api.kde.org/frameworks-api/apidox-frameworks/frameworks5-apidocs/plasma-framework/html/index.html
	* https://github.com/KDE/plasma-framework/tree/master/src/declarativeimports/
* [plasmapkg2 source code](https://github.com/KDE/plasma-framework/blob/master/src/plasmapkg/plasmapkg.cpp)
