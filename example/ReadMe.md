# Example plasmoid

This folder is useful for quickly writing a new plasmoid.

* `sh ./run` will run the `plasmoidviewer` command (part of `sudo apt install plasma-sdk`) with some sane default settings.
    * `QML_DISABLE_DISK_CACHE=true` will prevent Qt from cluttering your source code with `.qmlc` and `.jsc` files.
    * `QT_DEVICE_PIXEL_RATIO=2` will test 2x DPI
    * `LANG=fr_FR.UTF-8` will test the French locale (language).
* Do *not* run the `install`/`reinstall` scripts with `sudo` or the plasmoid will be placed in `/usr/share/` instead of your home directory.
* `sh ./build` will zip the contents of the `package` folder into a `example-v1.plasmoid` for when you're ready to upload to the [KDE Store](http://store.kde.org).
* `project.sublime-project` You can go ahead and delete this if you don't use Sublime Text.
    * If you use ST though, you can easily test with `Ctrl+B` after chosing the build system (Tools > Build System > Project).

## Locations

* `/usr/share/plasma/plasmoids/`  
  Where KDE's default plasmoids are stored.
* `~/.local/share/plasma/plasmoids/`  
  Where downloaded plasmoids are stored. It's also where this example plasmoid will be installed to.

## Other Examples Repositories

Note that official KDE software is only mirrored on github, however github is much better for navigating the codebase.

* https://github.com/KDE/plasma-desktop/tree/master/applets
* https://github.com/KDE/plasma-workspace/blob/master/applets
* https://github.com/KDE/kdeplasma-addons/tree/master/applets
* https://github.com/KDE/plasma-pa/tree/master/applet
* https://github.com/KDE/plasma-nm/tree/master/applet
* https://github.com/KDE/discover/tree/master/notifier
* https://github.com/kotelnik/plasma-applet-weather-widget
* https://github.com/kotelnik/plasma-applet-redshift-control
* https://github.com/psifidotos/nowdock-plasmoid
* https://github.com/psifidotos/nowdock-panel
* https://github.com/dfaust/plasma-applet-netspeed-widget
* https://github.com/dfaust/plasma-applet-popup-launcher
* https://github.com/dfaust/plasma-applet-places-widget


## Documentation

* Plasma API Tutorials
	* Getting Started  
		https://techbase.kde.org/Development/Tutorials/Plasma5/QML2/GettingStarted
	* API Reference / Overview  
		https://techbase.kde.org/Development/Tutorials/Plasma2/QML2/API
* [QML documentation](http://doc.qt.io/qt-5/qtqml-syntax-basics.html)
* plasma-framework (PlasmaCore, PlasmaComponents, etc) API Documentation  
	https://api.kde.org/frameworks/plasma-framework/html/index.html
	* Source Code  
		https://github.com/KDE/plasma-framework/tree/master/src/declarativeimports/
* [plasmapkg2 source code](https://github.com/KDE/plasma-framework/blob/master/src/plasmapkg/plasmapkg.cpp)
