[b]v39 - November 30 2016[/b]

* Fixed clock height is no longer limited to a max of 99px.
* Fix current date not advancing when used as a desktop widget.
* Fix weather/events being spam fetched XX times when first loaded (using the deferred pattern). This caused the tooltip to jitter for a bit as all the responses came in and caused updates.
* Panel tooltip now shows the seconds + timezone (still follows the locale instead of your 12h/24h setting though).
* Added "Big Number" style for the current date.
* Added a full height single column layout where the agenda is placed above the calendar.
* Refactor cached weather/event models so it's stored at the widget scope rather than the popup scope.
* Refactor most configurable code to not pass config values but look at a global object.

[b]v38 - October 21 2016[/b]

* Fix inability to set the weather affecting new users.
* Fix bug when viewing the weather config page in Kubuntu 16.04.

[b]v37 - October 15 2016[/b]

* Default to using a qdbus command to change the volume (with the GUI).
* Don't force user to hit apply after opening the "Google Calendar" tab in the config.
* Option to toggle outlines of icons when the bg color set by the theme is ugly as sin.
* Added a GUI for chosing your city.
* Lots of work for using Weather Canada as as a data source (still unfinished).
* Show a message to either hide or configure the weather when city is not set.
* Ability to set a fixed clock height.
* Jump by 1% instead of 5% when setting the clock's 2nd line height.
* Added a new event badge with just the decimal number of events that day.

[b]v36 - August 5 2016[/b]

* Show the 3h weather forecast icons in the meteogram.
* Show calendar colour in the calendar tooltip.
* Number of hours shown in the meteogram is now configurable (default: 30 hours).
* Use chronometer icons in the Timer. Also use toggle buttons instead of checkboxes.

[b]v35 - July 3 2016[/b]

* Tooltips for 3h periods for the Meteogram.
* Toggles for hiding the calendar/agenda.
* Periodically refresh the calendar events and update the forecast.
* Fix defaulting to the "bottom bar" event badge when the "theme" event badge isn't supported.
* Change version of QtMultimedia dependency from 5.6 to 5.4.

[b]v34 - June 14 2016[/b]

* Fix clock scaling on vertical panels.
* Use the locale's timeformat by default.
* Can now also choose your theme's calendar event indicator. By default it uses the theme, or the old solid rectangle if on an older version of KDE.
* Included a dots event indicator showing if there's 0-3+ events on that day.
* Performance increase when drawing the agenda (specifically the invisible new event form).
* 24h labels in the meteogram and the calendar tooltips.

[b]v33 - June 13 2016[/b]

* Round percipitation if >1mm.
* Show past events in the current month.
* Fix last selected calendar not saving.
* Properly scale the widget when resized (eg: desktop widget).
* Add a pin button.
* The meteogram now takes up the entire top row when the timer is disabled.

[b]v32 - May 9 2016[/b]

* Fix in-progress multiday events positioning the current day in agenda in the wrong place.

[b]v31 - May 9 2016[/b]

* Highlight current weather, date, and events in progress.
* Add non persistent (bug) sound toggle in the timer.
* Scroll over the timer to add/remove a minute from the duration.
* Show mm percipitation label in each 3h period.
* Fix scrolling to selection. Reenable showing previous events earlier in the current month since it now scrolls to the current date properly.

[b]v30 - Apr 29 2016[/b]

* Fix events from next month not showing in the agenda when on the current month (when in the next 14 days).
* Add optional sound effect when timer completes. Now depends on QtMultimedia.
* Add clock preset with custom color.
* Show current version in the config.

[b]v29 - Apr 22 2016[/b]

* Fix full day events showing an extra day in the calendar.
* Only show events from the current month in the agenda (but always show the next 2 weeks).
* Add a few presets to the clock config.
* Add tooltip to events without events so its stays open when hovering over them.
* Optionally remember the selected calendar in the new event form.

[b]v28 - Apr 17 2016[/b]

* Fix full day events showing an extra day in agenda.
* Add digitalclock's week numbers.
* Add Fahrenheit + Kelvin options.
* Redesign mousewheel config section.

[b]v27 - Apr 15 2016[/b]

* Fix duplication of events longer than a month in the agenda.
* Performance tweak with events with really long durations (like years).

[b]v26 - Apr 14 2016[/b]

* Update meteogram on hour change.
* Event badges each day in the calendar for multiday events.
* Better event date formatting for multiday events.
* Terrible support for use as a desktop widget. A desktop widget is a fixed size, and only shows the popup calendar view. The background border doesn't scale to fit either, but you can resize it to fit the widget by clicking and holding the background, then resizing it.
* Don't serialize the google calendar login code to the config if not logged in.

[b]v25 - Apr 9 2016[/b]

* Calendar borders are optional.
* Multiday events are optionally shown each day in the agenda (not yet shown in the calendar).
* Tooltips when hovering agenda weather and in the calendar.
* Can change clock font and bold each line.

[b]v24 - Apr 7 2016[/b]

* Add current date to month view title when on the current month.
* Add very simple meteogram with 24 hour temp and percipitation. Needs to be rewritten.
* Support vertical panels.

[b]v23 - Apr 5 2016[/b]

* Fix plasmashell crashing in Plasma/Qt 5.6.
* Add ability to customize height of second line in the clock.

[b]v21 - Mar 29 2016[/b]

* Make the weather icons into a button that opens the current city's weather in the browser.
* Hide the weather description text, made the weather icon bigger. Both are customizable.
* Add optional second line in the clock.
* Fix the popup cutting off the bottom sometimes.

[b]v20 - Mar 26 2016[/b]

* Fix transparency of new agenda buttons.

[b]v19 - Mar 26 2016[/b]

* Use the zero padded hh:ss for the default 24h clock format.
* Fix the timeout on the timer completion notification.
* Added a slim coloured line next to events in the event's calendar's colour.
* Clicking a the day in the agenda will open up a quick new event form.
* Clicking the event in the agenda will open the event in the browser.


[b]v18 - Mar 24 2016[/b]

* Can now customize the date/time format in the clock.
* Fix hiding widgets getting permanently hidden, and the popup not getting resized.
* Use start/pause icons in the timer.
* Reduce the spacing + widen the timer buttons.

[b]v17 - Mar 24 2016[/b]

* Show minutes/date in the agenda events if relevant.
* Add ability to toggle the placeholder & timer widgets.
* A single click in the month view scrolls to the agenda item.

[b]v16 - Mar 23 2016[/b]

* Toggle 24 hour clock.
* Update the agenda when the access_token changes (like after the first sync) or when the weather city id is changed, or when calendars are hidden/revealed.
* Properly hide calendars (events aleady fetched were left in the agenda).

[b]v15 - Mar 23 2016[/b]

* Scrolling over the clock controls the volume.
* Support Multiple Calendars.

[b]v10 - Mar 23 2016[/b]

* First release version.
* Syncs with Google Calendar using Device Code OAuth (access token stored in applet configuration) instead of KAccounts.
* Double click a day in the MonthView to open the new event template in the browser.
