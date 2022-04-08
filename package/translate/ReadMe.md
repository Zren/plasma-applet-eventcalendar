> Version 7 of Zren's i18n scripts.

With KDE Frameworks v5.37 and above, translations are bundled with the `*.plasmoid` file downloaded from the store.

## Install Translations

Go to `~/.local/share/plasma/plasmoids/org.kde.plasma.eventcalendar/translate/` and run `sh ./build --restartplasma`.

## New Translations

1. Fill out [`template.pot`](template.pot) with your translations then open a [new issue](https://github.com/Zren/plasma-applet-eventcalendar/issues/new), name the file `spanish.txt`, attach the txt file to the issue (drag and drop).

Or if you know how to make a pull request

1. Copy the `template.pot` file and name it your locale's code (Eg: `en`/`de`/`fr`) with the extension `.po`. Then fill out all the `msgstr ""`.

## Scripts

* `sh ./merge` will parse the `i18n()` calls in the `*.qml` files and write it to the `template.pot` file. Then it will merge any changes into the `*.po` language files.
* `sh ./build` will convert the `*.po` files to it's binary `*.mo` version and move it to `contents/locale/...` which will bundle the translations in the `*.plasmoid` without needing the user to manually install them.
* `sh ./plasmoidlocaletest` will run `./build` then `plasmoidviewer` (part of `plasma-sdk`).

## Links

* https://zren.github.io/kde/docs/widget/#translations-i18n
* https://techbase.kde.org/Development/Tutorials/Localization/i18n_Build_Systems
* https://api.kde.org/frameworks/ki18n/html/prg_guide.html

## Examples

* https://l10n.kde.org/stats/gui/trunk-kf5/team/fr/plasma-desktop/
* https://github.com/psifidotos/nowdock-plasmoid/tree/master/po
* https://github.com/kotelnik/plasma-applet-redshift-control/tree/master/translations

## Status
|  Locale  |  Lines  | % Done|
|----------|---------|-------|
| Template |     219 |       |
| da       | 184/219 |   84% |
| de       | 215/219 |   98% |
| el       | 167/219 |   76% |
| es       | 190/219 |   86% |
| fi       | 215/219 |   98% |
| fr       | 186/219 |   84% |
| he       | 216/219 |   98% |
| it       | 215/219 |   98% |
| ja       | 183/219 |   83% |
| nl       | 219/219 |  100% |
| pl       | 157/219 |   71% |
| pt_BR    | 215/219 |   98% |
| pt_PT    | 214/219 |   97% |
| ru       | 213/219 |   97% |
| sl       | 193/219 |   88% |
| sv       | 179/219 |   81% |
| tr       | 183/219 |   83% |
| uk       | 157/219 |   71% |
| zh_CN    | 163/219 |   74% |
