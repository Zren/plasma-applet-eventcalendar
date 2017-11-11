> Version 3 of Zren's i18n scripts.

## Install Translations

Go to `~/.local/share/plasma/plasmoids/{{plasmoidName}}/locale/` and run `sh ./build --restartplasma`.

## New Translations

1. Fill out [`template.pot`](template.pot) with your translations then open a [new issue](https://github.com/Zren/plasma-applets/issues/new), name the file `spanish.txt`, attach the txt file to the issue (drag and drop).

Or if you know how to make a pull request

1. Copy the `template.pot` file and name it your locale's code (Eg: `en`/`de`/`fr`) with the extension `.po`. Then fill out all the `msgstr ""`.

## Scripts

* `./merge` will parse the `i18n()` calls in the `*.qml` files and write it to the `template.pot` file. Then it will merge any changes into the `*.po` language files.
* `./build` will convert the `*.po` files to it's binary `*.mo` version and move it to `contents/locale/...` which will bundle the translations in the *.plasmoid without needed the user to manually install them.
* `./install` will convert the `*.po` files to it's binary `*.mo` version and move it to `~/.local/share/locale/...`.
* `./test fr` will run `./merge` then `./build` then restart plasmashell with `LANGUAGE=fr plasmashell` (which tests the french language).

## Links

* https://techbase.kde.org/Development/Tutorials/Localization/i18n_Build_Systems

## Examples

* https://websvn.kde.org/trunk/l10n-kf5/fr/messages/kde-workspace/
* https://github.com/psifidotos/nowdock-plasmoid/tree/master/po
* https://github.com/kotelnik/plasma-applet-redshift-control/tree/master/translations

## Status
|Locale | Lines | % Done|
|-------|-------|-------|
|Template	|65	|	|
