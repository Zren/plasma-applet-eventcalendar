import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

Loader {
	id: editEventForm
	active: false
	visible: active
	Layout.fillWidth: true
	sourceComponent: Component {
		GridLayout {
			id: editEventItem
			columns: 2

			readonly property var event: events.get(index)

			Component.onCompleted: {
				agendaScrollView.positionViewAtEvent(agendaItemIndex, eventItemIndex)
				editLocationTextField.forceActiveFocus()
			}

			function submit() {
				logger.log('editEventItem.submit()')
				var event = events.get(index)
				logger.debugJSON('event', event)

				logger.debug('editDescriptionForm.text', editDescriptionTextField.text)
				// eventModel.setEventProperty(event.calendarId, event.id, 'description', editDescriptionTextField.text)
			}

			function cancel() {
				editEventForm.active = false
			}

			//---

			DurationSelector {
				id: durationSelector
				showTime: !isAllDayCheckBox.checked
				Layout.fillWidth: true
				Layout.columnSpan: 2
				enabled: false

				startDateTime: model.start.dateTime || new Date()
				endDateTime: model.end.dateTime || new Date()
			}

			RowLayout {
				Layout.columnSpan: 2

				PlasmaComponents.CheckBox {
					id: isAllDayCheckBox
					text: i18n("All day")
					checked: !!event.start.date
				}
			}

			//---

			EventPropertyIcon {
				source: "mark-location-symbolic"
			}
			PlasmaComponents.TextField {
				id: editLocationTextField
				Layout.fillWidth: true
				placeholderText: i18n("Add Location")
				text: model.location || ""
				onAccepted: {
					logger.log('editLocationTextField.onAccepted', text)
					var event = events.get(index)
					eventModel.setEventProperty(event.calendarId, event.id, 'location', text)
				}

				Keys.onEscapePressed: editEventForm.active = false
			}

			EventPropertyIcon {
				source: "view-calendar-day"
			}
			PlasmaComponents.ComboBox {
				id: eventCalendarId
				Layout.fillWidth: true
				model: [i18n("[No Calendars]")]
				enabled: false
				Component.onCompleted: {
					// AgendaView.__
					console.log('populateCalendarSelector', eventCalendarId, event.calendarId)
					populateCalendarSelector(eventCalendarId, event.calendarId)
				}
			}

			EventPropertyIcon {
				source: "x-shape-text"
				Layout.fillHeight: false
				Layout.alignment: Qt.AlignTop
			}
			PlasmaComponents.TextArea {
				id: editDescriptionTextField
				placeholderText: i18n("Add description")
				text: model.description || ""

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

			RowLayout {
				Layout.columnSpan: 2
				Item {
					Layout.fillWidth: true
				}
				PlasmaComponents.Button {
					text: i18n("Submit")
					implicitWidth: minimumWidth
					onClicked: editEventItem.submit()
				}
			}
		}
	}
}
