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
| Template |     214 |       |
| da       | 182/214 |   85% |
| de       | 214/214 |  100% |
| el       | 164/214 |   76% |
| es       | 189/214 |   88% |
| fr       | 185/214 |   86% |
| it       | 214/214 |  100% |
| ja       | 186/214 |   86% |
| nl       | 214/214 |  100% |
| pl       | 154/214 |   71% |
| pt_BR    | 189/214 |   88% |
| pt_PT    | 214/214 |  100% |
| ru       | 212/214 |   99% |
| sv       | 174/214 |   81% |
| tr       | 181/214 |   84% |
| uk       | 150/214 |   70% |
| zh_CN    | 159/214 |   74% |
