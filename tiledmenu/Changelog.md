## v10 - December 30 2016

* Chinese translations by https://github.com/lm789632
* Optimize updating the recent app list so it doesn't lag opening the menu.
* Clicking the user icon will now open a submenu with user manager/lock/logout/change user similar to Win10.

## v9 - December 27 2016

* Use the theme's background color for the sidebar instead of black.
* The app list icon size is now configurable.
* Add dictionary and windowsed widgets (eg: Calculator) to search results.

## v8 - December 21 2016

* Misc work for editing tiles.
* Support linking to user created custom .desktop files. Note that the label will be the filename, but the icon will work.
* You can now drag an app anywhere in the app list (not just the icon).
* Implement the context menu (right click menus) actions that are in the default menus (recent apps/actions/pin to taskbar). I filtered out "Add to Panel" and "Add to Desktop" since it isn't obvious that the user will want "Add as Launcher". The user can always drag the app to where they want as well.
* Make the current search filter button highlighted with a simple line instead of a box.
* Fuss with the A-Z header positioning.
* Expanding the sidebar now has a short transition. Pushing a button also has an effect.
* Prepare the utils for translating this and other widgets.

## v7 - November 26 2016

* Fix the white text on white bg in the "white" searchbox when using breeze dark.
* Support dropping on the empty area below the current favourites.
* Dropping a new favourite item will insert at that location instead of adding to the end of the list.
* Changed the search results to use the same ordering as Application Launcher (Merged) by default. You can also choose to use categorized sorting like Application Menu, but the order might not be ideal as the custom full text sorting was disabled.
* The panel icon now scales by default. A toggle was added to make it a fixed size (for thick panels).
* Added shortcuts to the KSysGuard, Dolphin, SystemSettings, Konsole, and System Info in the context menu.
* Added ability to toggle the Recent Apps.

## v6 - November 23 2016

* Add a push down effect when clicking a favourite.
* Bind Esc to close the menu.
* Support closing the menu with Meta.
* Focus on the search box when clicking the menu background (and dismiss the power/sidebar menu).
* Show the app description after the name by default instead of below it.

## v5 - November 14 2016

* Tile text can now be center or right aligned.
* App description can now be after the app name, or hidden altogether.
* Use the system-search-symbolic icon instead of search and system-search.
* Optionally use the "widget/frame.svg" #raised from the desktop theme for the sidebar. The background color is drawn underneath when the power menu is open (since most themes have the svg transparent).
* Fix the sidebar when an icon doesn't exist in the icon theme.

## v4 - November 12 2016

* Fix a number of scaling issues when using a non default DPI.

## v3 - November 11 2016

* Fix tile/sidebar colors reseting to black when configuring.
* Use sidebar color in power menu.
* Changed the color scheme for sidebar icons.
* Padding to the section headings.
* Assign the description color based on the text color.
* Use the icon hover effect from taskmanager instead of a solid rectangle for the panel icon.

## v2 - November 5 2016

* Configurable tile color (for when the desktop theme uses a weird background color).
* Configurable sidebar color (because black isn't always best).
* Configurable panel icon.
* The search box can now be configured to follow the desktop theme (still default to white though).
* Refactor the search results and app list to resuse the same code.
* Ability to drag files/launchers from dolphin to the favourites grid.
* Hovering the panel icon while dragging opens the menu.
* Use custom config style.

## v1 - October 23 2016

* First release posted on reddit (under the name kickstart).
* No configuration.
