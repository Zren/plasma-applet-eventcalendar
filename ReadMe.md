# Event Calendar Updated version


Plasmoid for a calendar+agenda with weather that syncs to Google Calendar.

## Screenshots

![](https://i.imgur.com/qdJ71sb.jpg)
![](https://i.imgur.com/Ow8UlFj.jpg)




## A) Install via GitHub

```
git clone https://github.com/ALikesToCode/plasma-applet-eventcalendar.git eventcalendar
cd eventcalendar
sh ./install
```

To update, run the `sh ./update` script. It will run a `git pull` then reinstall the applet. Please note this script will restart plasmashell (so you don't have to relog)!



## Update to GitHub master

If you're asked to test something, you can do so by installing the latest unreleased code.

Beforehand, uninstall the AUR version if you are running Arch (you can reinstall after testing).

Then install pen the Terminal and run the following commands. Please note the install script will restart plasmashell so that you don't have to relog.

```
sudo apt install git
git clone https://github.com/ALikesToCode/plasma-applet-eventcalendar.git eventcalendar
cd eventcalendar
sh ./install --restart
```

When you've finished testing, you may wish to reinstall the KDE Store or AUR version. First uninstall the widget with the following command, then reinstall your desired version of the widget.

```
sh ./uninstall
```

## Configure

1. Right click the Calendar > Event Calendar Settings > Google Calendar
2. Copy the Code and enter it at the given link. Keep the settings window open.
3. After the settings window says it's synched, click apply.
4. Go to the Weather Tab > Enter your city id for OpenWeatherMap. If their search can't find your city, try googling it with [site:openweathermap.org/city](https://www.google.ca/search?q=site%3Aopenweathermap.org%2Fcity+toronto).


