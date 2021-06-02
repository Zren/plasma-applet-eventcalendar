## v75 - June 1 2021

* Show conference button for Google Meet and Zoom by @gaganpreet (Issue #63 and Pull Request #243)
* Fix parsing WeatherCanada AB/MB city list.
* Move the calendar name in the tooltip below the description like on Google Calendar.
* Complete German translations by @TimL20 (Pull Request #237)
* Update Italian translations by @guidomazzone (Pull Request #234)
* Update Portuguese translations by @dmmleal (Pull Request #232)

## v74 - March 24 2021

* Make PlasmaNM optional using a QML Loader (Issue #212)
* Fix HTTP request code to fix weather not updating on connect when using OpenWeatherMap (Issue #218)
* Fix daily forecast in agenda when using WeatherCanada and add error handling.
* Show a notification 15min before events starts. Defaults with no sfx but can be enabled. (PR #221)
* Implement expiresTimeout in notification.py should we want notification to last longer in the future.
* Add event tooltip to agenda that always displays the calendar name, and the description if it's been hidden (Issue #152 and #195)
* Limit event description to 5 lines by default (Issue #196)
* Shift js files around. Use === instead of ==.
* Wrap hangout ToolButton in a Loader so we avoid creating unused controls (which loads an svg) when creating events.
* Add Portuguese european translations by @dmmleal (Pull Request #226 and #230)
* Updated Dutch translation by @Vistaus (Pull Request #228)

## v73 - January 18 2021

* Add a NetworkMonitor to detect when there's no internet (Issue #113)
* Automatically close HTTP 0 network not connected errors when reconnected (Issue #205)
* Fix timer sfx not working in certain locales (Issue #209)
* Update Russian translations by driglu4it on Element

## v72 - December 22 2020

* Only store the filename for enabled PlasmaCalendar plugins (Issue #204)
* Check if gcal items is undefined before reading length (Issue #203)
* Use 90% color step from bg to text for grid (Issue #201)
* icsjson.py fixes by @koosvriezen (Pull Request #184)
* Add Swedish translations by @EazyDefcon (Issue #197)
* Updated Italian translation by @guidomazzone (Pull Request #182)
* Updated Dutch translation by @Vistaus (Pull Request #184)

## v71 - November 13 2020

* Change the Google API key as we were hiting the daily quota due to 1 user still using v63. This requires you to re-login to Google Calendar Sync.
* Display alerts above the agenda when a widget update changes the API key. Also displays alerts when the web requests to google return with an error.
* Refactor the code of most config options. They old config values should migrate cleanly for the next few versions before the migration code is removed.
* Remove the final QtMultimedia use in ConfigSound to fix the config window crashing on Kubuntu and OpenSUSE (Issue #167)
* Allow double click in the Calendar to do nothing by @matty-r (Pull Request #170)
* Refactor Timer as QML Timer is untrustworthy on high refresh screens (Issue #129)
* Jump timer by 5min when duration over 15min or seconds when under 1min
* Disable the timer sfx control when showTimer=false (Pull Request #172)
* Can now configure the calendar's title date format by @matty-r (Pull Request #176)
* Use ColorScheme colors for GoogleCal login text. Also fix poorly colored date format preset buttons.
* Now uses a semi-transparent text color as the agenda item hover color when the color theme has low contrast. This fixes Oxygen's white on white when hovering.
* Merge reinstall code into the install script. Also add uninstall script.
* Add Italian translation by @guidomazzone (Issue #169 and Pull Request #179)

## v70 - October 14 2020

* Fix Save/Save/Cancel buttons in Edit Timer/Task/Event forms that were invisible in latest KDE Frameworks.
* Fix bug where toggling timer sfx in config doesn't apply change.
* Show CheckBox in NewEventForm when tasklist is selected. Gives a visual cue that the last event added was a task instead of an event.
* Vertical Align "to" text in DurationSelector.
* Fix EventItem height bug after closing EditForm.
* Add EditTaskForm based EditEventForm.
* Remove "notifications" dataengine to support Latte Dock (Issue #60). We also remove the QtMultimedia sfx that caused issues in (Issue #84). We now use notification.py for events as well. I've done my best to sanitize the event summary + body.
* Implement konsolekalendar add event with PIM calendars (Issue #43). Also added a konsolekalendar.py script to find the uid of an event.
* Check for err before parsing oauth token data. (Issue #147)
* Updated Dutch translations by @Vistaus (Pull Request #164)

## v69 - July 27 2020

* Add copy to clipboard in contextual actions by @navarroaxel (Pull Request #142) (Issue #28). Widget now requires Plasma 5.13.
* Swap Agenda and Calendar positions like Digital Clock will in Plasma 5.20. The Calendar appears above the Agenda when in single column mode.
* The Calendar height in single column mode has been shrunk to 300px from 400px by default so there's more room for events. The 300px is configurable in the config if you dislike the rectangular cells in the Calendar.
* The padding is now the size of the pin button when in 2 column mode when the meteogram + timer is hidden. The padding has been removed from single column mode except for the top to make room for the pin button.
* Meteogram is no longer taller when in single column mode.
* Enabled the WeatherCanada weather source.
* Refactor weather code to pass the config instead of using a global variable.
* Move event fetching logic in PopupView to main context so that it doesn't need to load when we open the popup (Issue #40 and #127)
* If precipitation label is same as last data point, then don't bother drawing it. This makes WeatherCanada graphs readable.
* Now highlights current day + current week number. Can be turned off in the config.
* New Layout tab for switching between two column and single column mode. Includes ability to resize the Calendar, Agenda, Meteogram and Timer in two column mode.
* Fix timer complete sfx in Ubuntu. I didn't realize `canberra-gtk-play` wasn't installed by default. The `notification.py` now hooks into `libcanberra.so` via directly with Python to play sound effects. (Issue #128)
* Fix centering weather temp + text in Agenda.
* Various controls in the config no longer require pressing Apply.
* When an event has a Google Meet link, it used to show "Hangout", now it'll show "Google Meet".
* Integrrated Google Tasks. You cannot yet edit Tasks from Plasma, but you can create, delete, and toggle them complete. Unfortunately, there's a 50,000 requests API limit unlike Google Calendar with has a 1MM daily limit so it might hit the rate limit. You may need to logout and log back in in the widget's config to update your permissions to accept Google Tasks. (Issue #57)
* Refactored Google Calendar code to support another adding/deleting events for another "Calendar" plugin  (Google Tasks).
* Refactor to use PlasmaComponents3/QtQuickControls2, and Kirigami Units/Colors in the config.
* Don't consider weather updated if we didn't connect (Issue #144)
* Typos fixed by @navarroaxel (Pull Request #146)
* Updated Japanese translations by @ymadd (Pull Request #140 and #149)
* Updated Dutch translations by @Vistaus (Pull Request #148)

## v68 - June 26 2020

* Added Japanese translations by @ymadd (Pull Request #139)

## v67 - June 23 2020

* Fix event creation (Issue #137)
* Workaround hardcoded top/bottom padding in clock text (Issue #6). Note that fixing this has made "Fixed Font Height" text larger so you will need to manually adjust it smaller after the update. Scale to fit now uses the same size as Digital Clock, where 1 line is 71% panel height, and 2 lines uses the entire height.
* Add option to hide 'All Day' text in the agenda so all day events take up less vertical space. Location is placed next to the summary if it is set.
* Configurable spacing between days/events. Doubled day spacing to 20px.
* Update ru translations by @aliger14 (Pull Request #124)
* Update pt_BR translations by @herzenschein (Pull Request #125)
* Update nl translations by @Vistaus (Pull Request #138)

## v66 - December 22 2019

* Fix problem with Qt 5.14 (Issue #99) by @fedeliallalinea (Pull Request #110)
* Refactor event timestamp handling.
* Show kholiday events by default in Arch/Manjaro.
* Allow timer buttons to grow wider (Issue #103)
* Use reusable translations for labels in timer.
* Use a python3 script to show timer is done notifications, which allows us to add a repeat (once) button to the notification.
* Show error message if there's an error when fetching the calendar list in the config window (Issue #18)
* Updated French translation by @gabriel-tessier (Pull Request #105)

## v65 - October 24 2019

* We only need QQC2 v2.0 for the google cal config page ContextMenu (Issue #102).
* Dynamically load the Audio sound effects so that it should fail if GStreamer or QtMultimedia crash (Issue #84).
* Updated Dutch translation by @Vistaus (Pull Request #97)
* Updated Spanish translation by @V3ct0r (Pull Request #100)

## v64 - October 6 2019

* Notice: On June 18-19, Google Calendar suffered an outage, exposing a bug in the widget. The widget was caught in a loop trying to update. A symptom of this was 100% usage causing a the taskbar to not be responsive. (Issue #85)
* Fix: Properly detect google calendar access token has expired errors. No longer assumes every error is an access token error. Detect when the rate limit has been reached. (Issue #85)
* Check if the access token has expired before editing the event summary/description, or creating/deleting an event. You no longer need to refresh the events first if it's been a long time since the last access token was fetched.
* Use HTTPS when connecting to OpenWeatherMap. When the widget was made, HTTPS was not available. Note that Google Calendar integration has always used HTTPS. (Issue #83)
* The refresh button will no longer force a refresh of the weather data. Weather will only manually update if it's been over an hour.
* Show an error message where the meteogram should be if there's an error at login. If the meteogram was populated, it will not show the error message as the user still has 3 days of hourly data to use.
* Only fetch the Weather Canada city data when the dialog opens. It was opening every time the weather config tab was selected.
* Refactor the weather code.
* Show event location next to event start/end time (Issue #68)
* Add a more complete edit event form that can edit the location. Editing date/time, or moving the event to another calendar are not yet implemented and are disabled.
* Show calendar color in New Event Form.
* Use short time format in tooltip for extra timezones like digitalclock.
* Can right click the link to sync login with google calendar in order to copy the url if you use the Brave web browser (Issue #87)
* Updated Chinese translation by @Core00077 (Pull Request #80)
* Updated French translation by @Cherkah (Pull Request #90)
* Updated Dutch translation by @Vistaus (Pull Request #91)
* Add turkish translations by @eggsywashere (Issue #82)
* Verified with Google sensitive APIs.

## v63 - May 17 2019

* Add 'Edit Description' to context menu to quickly edit the description.
* Scroll to top of event when we edit the summary/description instead of the day.
* Fix heading colors (Issue #70)
* Add Chinese translation by @Core00077 (Pull Request #71)
* Add Danish translation by @cedeel (Pull Request #73)
* Updated Portuguese Brazilian translations by @herzenschein (Pull Request #75)
* Translate widget name in es, de, nl, pt, pt_BR (Pull Request #78)
* Updated Dutch translation by @Vistaus (Pull Request #79)

## v62 - February 10 2019

* Update Russian translations by @aliger14 (Pull Request #44)
* Bundle the google calendar icon for the config tab icon.
* Add the plasmoidlocaletest script for testing translations
* Fix Typo. "Chose" is past tense, "Choose" is present.
* Rewrite the google login code to use a different login method. Instead of pasting a code into the web browser, you now paste a (longer) code into the widget. This change will allow us to possibly use the Google Keep/Reminder APIs in the future.
* Tabify/Cleanup all code.
* Use correct date format in tooltip (by @jstarzyk)
* Disable "Always keep current agenda date/weather in view when scrolling" to confirm it's not causing issues.

## v61 - September 13 2018

* Show the event description and hangout link.

## v60 - September 5 2018

* Fix "D" in date formatting with Dutch translations.
* Add ability to change first day of the week without changing the System locale/formats (Issue #32).
* Add Polish translations by @jstarzyk (PR #34).
* Fix "Astrological Events" duration formatting (Issue #25).
* Fix one of the Date presets in the config showing up blank.

## v59 - August 1 2018

* Fix OpenWeatherMap city selector dialog.
* Updated Dutch translation by @Vistaus.

## v58 - June 26 2018

* Add ability to set a custom timer via right clicking the timer > "Set Timer".
* Fix regression where the "event update interval" was not saving.
* Make sure we translate `*.js` files too.

## v57 - June 18 2018

* Always keep current agenda date/weather in view when scrolling.
* Show an error message when we couldn't connect to google cal server. When generating a user code to login.
* Various refactoring.
* Add Greek translations by @linxtone.
* Add Dutch translations by @Vistaus.

## v56 - May 12 2018

* Fix KHolidays/PIM events showing up a day early when in a timezone before GMT (eg: +01:00).
* Use "day month, year" for calendar title in russian translations.

## v55 - March 21 2018

* Fix KHolidays/PIM events not appearing when viewing other months
* Filter duplicates caused by multi-day events in Plasma plugins (KHolidays/PIM).
* Use PIM event colors.

## v54 - March 16 2018

* Refactor event badges so that we don't create+bind every style.
* Don't generate calendar tooltip text until hovered over.
* Make sure agenda follows system settings font size.
* Support custom font size in the agenda.
* Update github install and add git master testing instructions.
* Copy the fixed width code from digitalclock. Modified to work with event calendar's ability to use Rich Text formatting.
* Support Plasma's event plugin (KHolidays is enabled by default but you still need to select your region in the config).
* Russian translations by @aliger14.

## v53 - Febuary 2 2018

* Fix scrolling to current date after all events have loaded.
* Recently, google has updated the google calendar website to a material design, editing an event in the browser would link to the month view instead of the full editor. I've changed the link opened so it's now opening the full event editor.
* Refactored code to draw all event on loading them instead of a slight lag when scrolling when it tries to generate them on demand.
* Because of the refactor, the agenda now has a scrollbar.
* When fetching events, it will now wait a little bit for another calendar before redrawing everything.
* Reuse existing event placeholders instead of deleting them all and generating new ones. This alleviates some of the memory creep (but not all).
* Fix weather column cells not resizing when too small.
* Merge fr translations by @Amathadius.
* Rename the translation folder.

## v52 - January 12 2018

* Move widget to it's own github repo (https://github.com/Zren/plasma-applet-eventcalendar).
* Show starting date for multi-day events already in progress.
* Support more than 250 events in a single month in a calendar.
* Some minor refactoring / code cleanup.

## v51 - November 20 2017

* Ukrainian translations by cappelikan.
* Add link to set language from context menu.
* Wrap the event descriptions.
* Support moving weather icon to the right side in the agenda (like Event Flow Calendar).
* Don't wrap the calendar title when the widget is small, use an elipsis (...).
* Dynamically reveal the timer preset buttons if there's enough space. Hidden presets are still available in a context menu when right clicking the timer pause button.
* Added a 20m timer preset, which will hide the 60m preset by default.
* Hide the timer toggle button labels when there isn't enough space.

## v50 - October 27 2017

* [KDE Store] Translations are now bundled without the need to manually install them (requires KDE Frameworks v5.37).
* Added Portuguese Brazil (pt_BR) translations by clayzanfolin.
* Added notification sound when an event starts.
* Added ability to toggle event starting notification and sound, and ability to customize which sound.
* Fix bug where locales using 24 hour clock wasn't used by default.
* Support creating events for and editing Google Calendar events when you have the "writer" role (instead of "owner") [patched by lknop].
* [upstream] Persistent pin open state after relogging. https://phabricator.kde.org/D8252

## v49 - September 15 2017

* Fix inability to logout of google calendar which got broken during earlier refactoring.
* Show notification when an event is added or deleted.
* Lots of refactoring needed for supporting different calendar backends.

## v48 - July 7 2017

* Add Spanish translation by Zipristin
* Fix plasmashell crash when closing eventcalendar's config window.
* Support extra timezones in the tooltip based on digitalclock.
* The meteogram colors are now configurable.
* The in progress color in the agenda is now configurable.

## v47 - June 9 2017

* Add German translation by frispete
* Add button in the config to simply installing translations (hopefully it works).
* Ability to set colors in the agenda/meteogram. Only available in the debugging/advanced view for now. A simpler editor will come soonish.
* Scale meteogram/agenda icons based on the DPI.
* Show clickable date in agenda for each day in selected month.
* Wait 100ms after receiving events before updating the interface. Should minimize stuttering when events are loading.

## v46 - April 27 2017

* Add ability to set the radius of the selected date.
* Fix different sized labels (for 1-9 vs 10-31) in the calendar when the cell height is greater than the width.
* French translations by Amathadius.

## v45 - April 22 2017

* Get rid of padding between event summary and the timestamp.
* Polish the Google calendar list in the config. Adding a refresh list button, mark which calendars are read only, and sort the list alphabetically.
* [upstream] Shrink and elide week names like is done with day delegate

## v44 - April 8 2017

* Fix "ConfigSerializedString.qml is missing" error when installed via a package manager that downloaded from GitHub by commiting the file.
* Support event specific colors. When a specific event is assigned a color, a colorId is used rather than a hex color (#ffffff). So we package a hardcoded set of colours for now until we download the user selected colors from the API.

## v43 - April 6 2017

* A notification is now displayed when an event is starting.
* Can now delete non-reoccuring events from the context menu.
* Prepare widget for translations (thanks Victor).
* Use same popup size as digital clock when only the calendar widget is enabled.
* A new event badge has been added which shows all the colors for that day in a line.
* Add toggle for hiding the background when used as a desktop widget.
* Close new event form with Esc
* Support kelvin/fahrenheit freezing points (below freezing the meteogram line turns blue).
* Refactor the config code. Add an advanced debugging view.
* Show calendar colours in the config.
* When the meteogram is disabled, move the timer to the top right, and have the agenda consume the entire left half of the popup.
* Fix timer overlaying the calendar when using a non-default font size.

## v42 - February 14 2017

* Possible fix for emojis in the event summary crashing plasmashell.

## v41 - February 13 2017

* Hide the daily weather column if there's no data.
* Add new clock preset.
* Add debugging mode.

## v40 - February 6 2017

* Can now edit the event summary (except for repeating events) from the right click menu.
* A few HiDPI fixes from @vcucek. Begin testing with 2x DPI.
* [upstream fix] Fix "title" button's height in the calendar.
* Refactor the event fetching code so it's not cluttering UI files.
* Cleanup some debug logging + warnings.
* Change whitespace between weather/date/events in the agenda to padding inside the button.

## v39 - November 30 2016

* Fixed clock height is no longer limited to a max of 99px.
* Fix current date not advancing when used as a desktop widget.
* Fix weather/events being spam fetched XX times when first loaded (using the deferred pattern). This caused the tooltip to jitter for a bit as all the responses came in and caused updates.
* Panel tooltip now shows the seconds + timezone (still follows the locale instead of your 12h/24h setting though).
* Added "Big Number" style for the current date.
* Added a full height single column layout where the agenda is placed above the calendar.
* Refactor cached weather/event models so it's stored at the widget scope rather than the popup scope.
* Refactor most configurable code to not pass config values but look at a global object.

## v38 - October 21 2016

* Fix inability to set the weather affecting new users.
* Fix bug when viewing the weather config page in Kubuntu 16.04.

## v37 - October 15 2016

* Default to using a qdbus command to change the volume (with the GUI).
* Don't force user to hit apply after opening the "Google Calendar" tab in the config.
* Option to toggle outlines of icons when the bg color set by the theme is ugly as sin.
* Added a GUI for chosing your city.
* Lots of work for using Weather Canada as as a data source (still unfinished).
* Show a message to either hide or configure the weather when city is not set.
* Ability to set a fixed clock height.
* Jump by 1% instead of 5% when setting the clock's 2nd line height.
* Added a new event badge with just the decimal number of events that day.

## v36 - August 5 2016

* Show the 3h weather forecast icons in the meteogram.
* Show calendar colour in the calendar tooltip.
* Number of hours shown in the meteogram is now configurable (default: 30 hours).
* Use chronometer icons in the Timer. Also use toggle buttons instead of checkboxes.

## v35 - July 3 2016

* Tooltips for 3h periods for the Meteogram.
* Toggles for hiding the calendar/agenda.
* Periodically refresh the calendar events and update the forecast.
* Fix defaulting to the "bottom bar" event badge when the "theme" event badge isn't supported.
* Change version of QtMultimedia dependency from 5.6 to 5.4.

## v34 - June 14 2016

* Fix clock scaling on vertical panels.
* Use the locale's timeformat by default.
* Can now also choose your theme's calendar event indicator. By default it uses the theme, or the old solid rectangle if on an older version of KDE.
* Included a dots event indicator showing if there's 0-3+ events on that day.
* Performance increase when drawing the agenda (specifically the invisible new event form).
* 24h labels in the meteogram and the calendar tooltips.

## v33 - June 13 2016

* Round percipitation if >1mm.
* Show past events in the current month.
* Fix last selected calendar not saving.
* Properly scale the widget when resized (eg: desktop widget).
* Add a pin button.
* The meteogram now takes up the entire top row when the timer is disabled.

## v32 - May 9 2016

* Fix in-progress multiday events positioning the current day in agenda in the wrong place.

## v31 - May 9 2016

* Highlight current weather, date, and events in progress.
* Add non persistent (bug) sound toggle in the timer.
* Scroll over the timer to add/remove a minute from the duration.
* Show mm percipitation label in each 3h period.
* Fix scrolling to selection. Reenable showing previous events earlier in the current month since it now scrolls to the current date properly.

## v30 - Apr 29 2016

* Fix events from next month not showing in the agenda when on the current month (when in the next 14 days).
* Add optional sound effect when timer completes. Now depends on QtMultimedia.
* Add clock preset with custom color.
* Show current version in the config.

## v29 - Apr 22 2016

* Fix full day events showing an extra day in the calendar.
* Only show events from the current month in the agenda (but always show the next 2 weeks).
* Add a few presets to the clock config.
* Add tooltip to events without events so its stays open when hovering over them.
* Optionally remember the selected calendar in the new event form.

## v28 - Apr 17 2016

* Fix full day events showing an extra day in agenda.
* Add digitalclock's week numbers.
* Add Fahrenheit + Kelvin options.
* Redesign mousewheel config section.

## v27 - Apr 15 2016

* Fix duplication of events longer than a month in the agenda.
* Performance tweak with events with really long durations (like years).

## v26 - Apr 14 2016

* Update meteogram on hour change.
* Event badges each day in the calendar for multiday events.
* Better event date formatting for multiday events.
* Terrible support for use as a desktop widget. A desktop widget is a fixed size, and only shows the popup calendar view. The background border doesn't scale to fit either, but you can resize it to fit the widget by clicking and holding the background, then resizing it.
* Don't serialize the google calendar login code to the config if not logged in.

## v25 - Apr 9 2016

* Calendar borders are optional.
* Multiday events are optionally shown each day in the agenda (not yet shown in the calendar).
* Tooltips when hovering agenda weather and in the calendar.
* Can change clock font and bold each line.

## v24 - Apr 7 2016

* Add current date to month view title when on the current month.
* Add very simple meteogram with 24 hour temp and percipitation. Needs to be rewritten.
* Support vertical panels.

## v23 - Apr 5 2016

* Fix plasmashell crashing in Plasma/Qt 5.6.
* Add ability to customize height of second line in the clock.

## v21 - Mar 29 2016

* Make the weather icons into a button that opens the current city's weather in the browser.
* Hide the weather description text, made the weather icon bigger. Both are customizable.
* Add optional second line in the clock.
* Fix the popup cutting off the bottom sometimes.

## v20 - Mar 26 2016

* Fix transparency of new agenda buttons.

## v19 - Mar 26 2016

* Use the zero padded hh:ss for the default 24h clock format.
* Fix the timeout on the timer completion notification.
* Added a slim coloured line next to events in the event's calendar's colour.
* Clicking a the day in the agenda will open up a quick new event form.
* Clicking the event in the agenda will open the event in the browser.


## v18 - Mar 24 2016

* Can now customize the date/time format in the clock.
* Fix hiding widgets getting permanently hidden, and the popup not getting resized.
* Use start/pause icons in the timer.
* Reduce the spacing + widen the timer buttons.

## v17 - Mar 24 2016

* Show minutes/date in the agenda events if relevant.
* Add ability to toggle the placeholder & timer widgets.
* A single click in the month view scrolls to the agenda item.

## v16 - Mar 23 2016

* Toggle 24 hour clock.
* Update the agenda when the access_token changes (like after the first sync) or when the weather city id is changed, or when calendars are hidden/revealed.
* Properly hide calendars (events aleady fetched were left in the agenda).

## v15 - Mar 23 2016

* Scrolling over the clock controls the volume.
* Support Multiple Calendars.

## v10 - Mar 23 2016

* First release version.
* Syncs with Google Calendar using Device Code OAuth (access token stored in applet configuration) instead of KAccounts.
* Double click a day in the MonthView to open the new event template in the browser.
