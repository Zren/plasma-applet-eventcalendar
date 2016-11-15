import QtQuick 2.0
import QtQuick.Layouts 1.1

import org.kde.plasma.core 2.0 as PlasmaCore

Item {
	id: eventModel
	property variant eventsData: { "items": [] }
	property variant eventsByCalendar: { "": { "items": [] } }

	Component.onCompleted: {
		delete eventModel.eventsByCalendar[''] // Is there really no way to initialize an empty JSON object?
	}
}
