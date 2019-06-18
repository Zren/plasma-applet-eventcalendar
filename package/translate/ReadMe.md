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
* `./build` will convert the `*.po` files to it's binary `*.mo` version and move it to `contents/locale/...` which will bundle the translations in the *.plasmoid without needing the user to manually install them.
* `./install` will convert the `*.po` files to it's binary `*.mo` version and move it to `~/.local/share/locale/...`.
* `./plasmoidlocaletest` will run `./build` then `plasmoidviewer` (part of `plasma-sdk`).

## Links

* https://techbase.kde.org/Development/Tutorials/Localization/i18n_Build_Systems

## Examples

* https://websvn.kde.org/trunk/l10n-kf5/fr/messages/kde-workspace/
* https://github.com/psifidotos/nowdock-plasmoid/tree/master/po
* https://github.com/kotelnik/plasma-applet-redshift-control/tree/master/translations

## Status
|  Locale  |  Lines  | % Done|
|----------|---------|-------|
| Template |     194 |       |
| da       | 191/194 |   98% |
| de       | 139/194 |   71% |
| el       | 173/194 |   89% |
| es       | 142/194 |   73% |
| fr       | 152/194 |   78% |
| nl_NL    | 194/194 |  100% |
| pl       | 158/194 |   81% |
| pt_BR    | 191/194 |   98% |
| ru       | 179/194 |   92% |
| tr       | 194/194 |  100% |
| uk       | 158/194 |   81% |
| zh_CN    | 166/194 |   85% |
