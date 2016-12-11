> Version 1 of Zren's i18n scripts.

## Install Translations

Go to `~/.local/share/plasma/plasmoids/{{plasmoidName}}/locale/` and run `sh ./install`.

## New Translations

1. Copy the `template.pot` file and name it your locale's code (Eg: `en`/`de`/`fr`) with the extension `.po`. Then fill out all the `msgstr ""`.

## Scripts

* `./merge` will parse the `i18n()` calls in the `*.qml` files and write it to the `template.pot` file. Then it will merge any changes into the `*.po` language files.
* `./install` It will then convert the `*.po` files to it's binary `*.mo` version and move it to `~/.local/share/locale/...`.
* `./test` will run `./merge` then `./install`.

## Links

* https://techbase.kde.org/Development/Tutorials/Localization/i18n_Build_Systems

## Examples

* https://websvn.kde.org/trunk/l10n-kf5/fr/messages/kde-workspace/
* https://github.com/psifidotos/nowdock-plasmoid/tree/master/po
* https://github.com/kotelnik/plasma-applet-redshift-control/tree/master/translations

## Status
|Locale | Lines | % Done|
|-------|-------|-------|
|Template	|48	|	|
|pl	|0/48	|0%	|
|fr	|0/48	|0%	|
