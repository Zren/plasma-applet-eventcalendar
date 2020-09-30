import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents3

Loader {
	id: newEventForm
	active: false
	visible: active

	sourceComponent: Component {
		RowLayout {
			spacing: 4 * units.devicePixelRatio

			PlasmaComponents3.CheckBox {
				Layout.alignment: Qt.AlignHCenter | Qt.AlignTop
				Layout.preferredHeight: calendarSelector.implicitHeight
				enabled: false
				visible: calendarSelector.selectedIsTasklist
			}

			Rectangle {
				Layout.preferredWidth: appletConfig.eventIndicatorWidth
				Layout.fillHeight: true
				color: calendarSelector.selectedCalendar && calendarSelector.selectedCalendar.backgroundColor || theme.textColor
			}

			ColumnLayout {
				spacing: 10 * units.devicePixelRatio

				Component.onCompleted: {
					newEventText.forceActiveFocus()
					newEventFormOpened(model, calendarSelector)
				}
				CalendarSelector {
					id: calendarSelector
					Layout.fillWidth: true
				}

				RowLayout {
					PlasmaComponents3.TextField {
						id: newEventText
						Layout.fillWidth: true
						placeholderText: i18n("Eg: 9am-5pm Work")
						onAccepted: {
							var calendarEntry = calendarSelector.model[calendarSelector.currentIndex]
							// calendarId = calendarId.calendarId ? calendarId.calendarId : calendarId
							var calendarId = calendarEntry.calendarId
							if (calendarId && date && text) {
								submitNewEventForm(calendarId, date, text)
								text = ''
							}
						}
						Keys.onEscapePressed: newEventForm.active = false
					}
				}
			}

		}
	}
}
