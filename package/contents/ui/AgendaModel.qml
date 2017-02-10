import QtQuick 2.0
import QtQuick.Layouts 1.1

import org.kde.plasma.core 2.0 as PlasmaCore

ListModel {
	id: agendaModel
	property var eventModel
	property var weatherModel
	property bool showDailyWeather: false
}
