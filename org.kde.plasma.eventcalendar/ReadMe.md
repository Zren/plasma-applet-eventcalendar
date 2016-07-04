# Event Calendar

Plasmoid for a calendar+agenda with weather that synchs to Google Calendar.

https://www.kde-look.org/p/998901/

## Screenshots

![](https://i.imgur.com/C8uSVZf.png)
![](https://i.imgur.com/mXT23zo.png)


## Install via KDE

1. Right Click Panel > Panel Options > Unlock Widgets
2. Right Click Panel > Panel Options > Add Widgets
3. Get New Widgets > Download New Widgets
4. Search: Event Calendar
5. Install
6. Right Click your current calendar widget > Alternatives
7. Select Event Calendar

## Install via GitHub

```
git clone https://github.com/Zren/plasma-applets.git
cd plasma-applets/org.kde.plasma.eventcalendar
./install
```

To update, run the `./update` script. It will run a `git pull` then reinstall the applet. Please note this script will restart plasmashell (so you don't have to relog)!

## Install via Package Manager

Some awesome users seemed to have packaged this applet under `plasma5-applets-eventcalendar`.

* https://aur.archlinux.org/packages/plasma5-applets-eventcalendar/
* https://chakraos.org/ccr/packages.php?ID=7656


## Configure

1. Right click the Calendar > Event Calendar Settings > Google Calendar
2. Copy the Code and enter it at the given link. Keep the settings window open.
3. After the settings window says it's synched, click apply.
4. Go to the Weather Tab > Enter your city id for OpenWeatherMap. If their search can't find your city, try googling it with [site:openweathermap.org/city](https://www.google.ca/search?q=site%3Aopenweathermap.org%2Fcity+toronto).

