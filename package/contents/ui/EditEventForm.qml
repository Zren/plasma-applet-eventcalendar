import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents3

import "Shared.js" as Shared

Loader {
	id: editEventForm
	active: false
	visible: active
	Layout.fillWidth: true
	sourceComponent: Component {
		MouseArea {
			id: editEventItem

			onClicked: focus = true

			implicitWidth: editEventGrid.implicitWidth
			implicitHeight: editEventGrid.implicitHeight

			readonly property var event: events.get(index)

			Component.onCompleted: {
				agendaScrollView.positionViewAtEvent(agendaItemIndex, eventItemIndex)
				editSummaryTextField.forceActiveFocus()

				logger.debugJSON('EditEventForm.event', event)
			}

			function isEmpty(s) {
				return typeof s === "undefined" || s === null || s === ""
			}
			function hasChanged(a, b) {
				// logger.log('hasChanged', a != b)
				// logger.log('\t', JSON.stringify(a), typeof a, isEmpty(a))
				// logger.log('\t', JSON.stringify(b), typeof b, isEmpty(b))
				return a != b && !(isEmpty(a) && isEmpty(b))
			}
			function populateIfChanged(args, propKey, newValue) {
				var changed = hasChanged(event[propKey], newValue)
				// logger.log(propKey, changed, event[propKey], newValue)
				if (changed) {
					args[propKey] = newValue
				}
			}
			function populateIfDateChanged(args, propKey, newValue) {
				var changedDate = hasChanged(event[propKey]['date'], newValue['date'])
				var changedDateTime = hasChanged(event[propKey]['dateTime'], newValue['dateTime'])
				var changedTimeZone = hasChanged(event[propKey]['timeZone'], newValue['timeZone'])
				var changed = changedDate || changedDateTime || changedTimeZone
				// logger.logJSON('populateIfDateChanged', propKey, changed, event[propKey], newValue)
				// logger.log('\t', changedDate, changedDateTime, changedTimeZone)
				if (changed) {
					args[propKey] = newValue
				}
			}
			function getChanges() {
				var args = {}
				populateIfChanged(args, 'summary', editSummaryTextField.text)
				populateIfDateChanged(args, 'start', durationSelector.getStartObj())
				populateIfDateChanged(args, 'end', durationSelector.getEndObj())
				populateIfChanged(args, 'location', editLocationTextField.text)
				populateIfChanged(args, 'description', editDescriptionTextField.text)
				return args
			}
			function submit() {
				logger.log('editEventItem.submit()')
				logger.debugJSON('event', event)

				if (event.calendarId != calendarSelector.selectedCalendarId) {
					// TODO: Move event
					// TODO: Call setProperties after moving or vice versa.
					// https://developers.google.com/calendar/v3/reference/events/move
				}

				var args = getChanges()
				eventModel.setEventProperties(event.calendarId, event.id, args)
			}

			function cancel() {
				editEventForm.active = false
			}

			//---- Testing
			// Connections {
			// 	target: durationSelector
			// 	onStartDateTimeChanged: logger.logJSON('onStartDateTimeChanged', editEventItem.getChanges())
			// 	onEndDateTimeChanged: logger.logJSON('onEndDateTimeChanged', editEventItem.getChanges())
			// }

			//----
			GridLayout {
				id: editEventGrid
				anchors.left: parent.left
				anchors.right: parent.right
				columns: 2

				//---

				PlasmaComponents3.TextField {
					id: editSummaryTextField
					Layout.fillWidth: true
					Layout.columnSpan: 2
					placeholderText: i18n("Event Title")
					text: event && event.summary || ""
					onAccepted: {
						logger.debug('editSummaryTextField.onAccepted', text)
						editEventItem.submit()
					}

					Keys.onEscapePressed: editEventItem.cancel()
				}

				//---

				DurationSelector {
					id: durationSelector
					showTime: !isAllDayCheckBox.checked
					Layout.fillWidth: true
					Layout.columnSpan: 2

					startDateTime: {
						if (event && event.startDateTime) {
							if (event.start.date) {
								var d = new Date(event.startDateTime)
								// Set to 9-10am in case user unchecks All Day
								d.setHours(9)
								d.setMinutes(0)
								return d
							} else {
								return event.startDateTime
							}
						} else {
							return new Date()
						}
					}
					endDateTime: {
						if (event && event.endDateTime) {
							if (event.end.date) {
								// Events end at "midnight" the next day.
								// See parseEventsForDate() functions for more info.
								var d = new Date(event.endDateTime)
								d.setDate(d.getDate() - 1)
								// Set to 9-10am in case user unchecks All Day
								d.setHours(10)
								d.setMinutes(0)
								return d
							} else {
								return event.endDateTime
							}
						} else {
							return new Date()
						}
					}

					function getStartObj() {
						if (showTime) {
							return { dateTime: Shared.dateTimeString(startDateTime), timeZone: event.start.timeZone }
						} else { // All day
							return { date: Shared.dateString(startDateTime) }
						}
					}
					function getEndObj() {
						if (showTime) {
							return { dateTime: Shared.dateTimeString(endDateTime), timeZone: event.end.timeZone }
						} else { // All day
							// Events end at "midnight" the next day.
							// See parseEventsForDate() functions for more info.
							var dt = new Date(endDateTime)
							dt.setDate(dt.getDate() + 1)
							return { date: Shared.dateString(dt) }
						}
					}
				}

				RowLayout {
					Layout.columnSpan: 2

					PlasmaComponents3.CheckBox {
						id: isAllDayCheckBox
						text: i18n("All Day")
						checked: event ? !!event.start.date : false
						enabled: durationSelector.enabled
					}
				}

				//---

				EventPropertyIcon {
					source: "mark-location-symbolic"
				}
				PlasmaComponents3.TextField {
					id: editLocationTextField
					Layout.fillWidth: true
					placeholderText: i18n("Add location")
					text: event && event.location || ""
					onAccepted: {
						logger.debug('editLocationTextField.onAccepted', text)
						editEventItem.submit()
					}

					Keys.onEscapePressed: editEventItem.cancel()
				}

				EventPropertyIcon {
					source: "view-calendar-day"
				}
				CalendarSelector {
					id: calendarSelector
					Layout.fillWidth: true
					enabled: false
					Component.onCompleted: {
						var calendarList = eventModel.getCalendarList()
						calendarSelector.populate(calendarList, event.calendarId)
					}
				}

				EventPropertyIcon {
					source: "x-shape-text"
					Layout.fillHeight: false
					Layout.alignment: Qt.AlignTop
				}
				PlasmaComponents3.TextArea {
					id: editDescriptionTextField
					placeholderText: i18n("Add description")
					text: (event && event.description) || ""

					Layout.fillWidth: true
					Layout.preferredHeight: contentHeight + (20 * units.devicePixelRatio)

					Keys.onEscapePressed: editEventItem.cancel()

					Keys.onEnterPressed: _onEnterPressed(event) // ?
					Keys.onReturnPressed: _onEnterPressed(event) // What's triggered on a US Keyboard
					function _onEnterPressed(event) {
						// console.log('onEnterPressed', event.key, event.modifiers)
						if ((event.modifiers & Qt.ShiftModifier) || (event.modifiers & Qt.ControlModifier)) {
							editEventItem.submit()
						} else {
							event.accepted = false
						}
					}
				}

				//---

				RowLayout {
					Layout.columnSpan: 2
					spacing: 4 * units.devicePixelRatio
					Item {
						Layout.fillWidth: true
					}
					PlasmaComponents3.Button {
						icon.name: "document-save"
						text: i18n("&Save")
						onClicked: editEventItem.submit()
					}
					PlasmaComponents3.Button {
						icon.name: "dialog-cancel"
						text: i18n("&Cancel")
						onClicked: editEventItem.cancel()
					}
				}
			}

		}
	}
}
