> Version 4 of Zren's i18n scripts.

With KDE Frameworks v5.37 and above, translations are bundled with the *.plasmoid file downloaded from the store.

## Install Translations

Go to `~/.local/share/plasma/plasmoids/org.kde.plasma.eventcalendar/translate/` and run `sh ./build --restartplasma`.

## New Translations

1. Fill out [`template.pot`](template.pot) with your translations then open a [new issue](https://github.com/Zren/plasma-applet-eventcalendar/issues/new), name the file `spanish.txt`, attach the txt file to the issue (drag and drop).

Or if you know how to make a pull request

1. Copy the `template.pot` file and name it your locale's code (Eg: `en`/`de`/`fr`) with the extension `.po`. Then fill out all the `msgstr ""`.

## Scripts

* `./merge` will parse the `i18n()` calls in the `*.qml` files and write it to the `template.pot` file. Then it will merge any changes into the `*.po` language files.
* `./build` will convert the `*.po` files to it's binary `*.mo` version and move it to `contents/locale/...` which will bundle the translations in the *.plasmoid without needed the user to manually install them.
* `./install` will convert the `*.po` files to it's binary `*.mo` version and move it to `~/.local/share/locale/...`.
* `./test` will run `./merge` then `./install`.

## Links

* https://techbase.kde.org/Development/Tutorials/Localization/i18n_Build_Systems

## Examples

* https://websvn.kde.org/trunk/l10n-kf5/fr/messages/kde-workspace/
* https://github.com/psifidotos/nowdock-plasmoid/tree/master/po
* https://github.com/kotelnik/plasma-applet-redshift-control/tree/master/translations

## Status
|  Locale  |  Lines  | % Done|
|----------|---------|-------|
| Template |     187 |       |
| de       | 143/187 |   76% |
| el       | 177/187 |   94% |
| es       | 146/187 |   78% |
| fr       | 156/187 |   83% |
| nl_NL    | 187/187 |  100% |
| pt_BR    | 153/187 |   81% |
| ru       | 177/187 |   94% |
| uk       | 162/187 |   86% |
