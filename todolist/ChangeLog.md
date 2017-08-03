## v7 - August 3 2017

* Support multiple lists side by side. Each list is seperated by a heading in the file.
* Can drag and drop the lists to reorder them. Can drag items between lists.
* Can add a new list via the context menu. The delete button will prompt before deleting.
* Lines have the excess whitespace at the end of the line stripped.

## v6 - June 28 2017

* Fix height calculation (we ignored the height taken by the pin button).
* Use Plasma's panel icon size (which can be set in System Settings > Icons > Advanced).

## v5 - May 7 2017

* Remove ability to hide completed items.
* Added ability to remove items when completed instead, which will hide the "delete item" button (this is the new default).
* Added ability to reorder items.
* Focus on "new item" when popup is opened.
* Add scrollbar.
* Disable copy/cut/paste context menu so it's easier to open the widget context menu.

## v4 - December 14 2016

* Fix bug overwriting the wrong index when hiding completed items.

## v3 - December 14 2016

* Show the number of incomplete icons in the panel icon using the same badge as the taskmanager (file transfer / downloads).
* Fix adjusting the height according to the number of items displayed (shouldn't show a scrollbar until it's taller than the screen).

## v2 - August 31 2016

* Support KDE 5.5 / Qt 5.5
* Support tabs when editing the file itself. Also automatically indent when the file is saved.
* Remove a ton of excess logging.
