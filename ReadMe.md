# Event Calendar

https://store.kde.org/p/998901/

Plasmoid for a calendar+agenda with weather that syncs to Google Calendar.

## Screenshots

![](https://i.imgur.com/qdJ71sb.jpg)
![](https://i.imgur.com/Ow8UlFj.jpg)


## A) Install via KDE

1. Right Click Panel > Panel Options > Add Widgets
2. Get New Widgets > Download New Widgets
3. Search: Event Calendar
4. Install
5. Right Click your current calendar widget > Alternatives
6. Select Event Calendar

## B) Install via GitHub

```
git clone https://github.com/Zren/plasma-applet-eventcalendar.git eventcalendar
cd eventcalendar
sh ./install
```

To update, run the `sh ./update` script. It will run a `git pull` then reinstall the applet. Please note this script will restart plasmashell (so you don't have to relog)!

## C) Install via Package Manager

Some awesome users seemed to have packaged this applet under `plasma5-applets-eventcalendar`.

* Arch: https://aur.archlinux.org/packages/plasma5-applets-eventcalendar/
* Chakra: https://chakralinux.org/ccr/packages.php?ID=7656

(Old) There's also a russian who's patched the widget with russian translations. It's out of date though, and we now bundle russian translations with the rest.

* ABF: https://abf.rosalinux.ru/victorr2007/plasma5-applet-eventcalendar

## Update to GitHub master

If you're asked to test something, open the Terminal and run the following commands.

```
sudo apt install git
git clone https://github.com/Zren/plasma-applet-eventcalendar.git eventcalendar
cd eventcalendar
sh ./reinstall
```

Please note this script will restart plasmashell (so you don't have to relog)!

## Configure

1. Right click the Calendar > Event Calendar Settings > Google Calendar
2. Copy the Code and enter it at the given link. Keep the settings window open.
3. After the settings window says it's synched, click apply.
4. Go to the Weather Tab > Enter your city id for OpenWeatherMap. If their search can't find your city, try googling it with [site:openweathermap.org/city](https://www.google.ca/search?q=site%3Aopenweathermap.org%2Fcity+toronto).


