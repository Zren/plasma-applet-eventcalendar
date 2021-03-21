import QtQuick 2.0
import QtQuick.Layouts 1.1

import org.kde.plasma.core 2.0 as PlasmaCore

Item {
	id: timeModel
	property string timezone: "Local"
	property var currentTime: dataSource.data[timezone]["DateTime"]
	property alias dataSource: dataSource
	property var allTimezones: {
		var timezones = plasmoid.configuration.selectedTimeZones.toString()
		if (timezones.length > 0) {
			timezones = timezones.split(',')
		} else {
			timezones = []
		}
		if (timezones.indexOf('Local') === -1) {
			timezones.push('Local')
		}
		return timezones
	}

	signal secondChanged()
	signal minuteChanged()
	signal dateChanged()
	signal loaded()

	PlasmaCore.DataSource {
		id: dataSource
		engine: "time"
		connectedSources: timeModel.allTimezones
		interval: 1000
		intervalAlignment: PlasmaCore.Types.NoAlignment
		onNewData: {
			if (sourceName === 'Local') {
				timeModel.tick()
			}
		}
	}

	property bool ready: false
	property int lastMinute: -1
	property int lastDate: -1
	function tick() {
		if (!ready) {
			ready = true
			loaded()
		}
		secondChanged()
		var currentMinute = currentTime.getMinutes()
		if (currentMinute != lastMinute) {
			minuteChanged()
			var currentDate = currentTime.getDate()
			if (currentDate != lastDate) {
				dateChanged()
				lastDate = currentDate
			}
			lastMinute = currentMinute
		}
	}


	property bool testing: false
	Component.onCompleted: {
		if (testing) {
			currentTime = new Date(2016, 1, 2, 23, 59, 55)
			timeModel.loaded()
		}
	}

	Timer {
		running: testing
		repeat: true
		interval: 1000
		onTriggered: {
			currentTime.setSeconds(currentTime.getSeconds() + 1)
			timeModel.currentTimeChanged()
			timeModel.tick()
		}
	}
}
