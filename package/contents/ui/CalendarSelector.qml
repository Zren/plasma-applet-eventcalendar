import QtQuick 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents3

PlasmaComponents3.ComboBox {
	id: calendarSelector
	model: [
		{ text: i18n("[No Calendars]") }
	]
	textRole: "text"

	readonly property var selectedCalendar: currentIndex >= 0 ? model[currentIndex] : {}
}
