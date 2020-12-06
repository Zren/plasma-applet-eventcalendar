import QtQuick 2.0
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents3
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.private.digitalclock 1.0 as DigitalClock

Item {
	id: tooltipContentItem

	property int preferredTextWidth: units.gridUnit * 20

	width: childrenRect.width + units.gridUnit
	height: childrenRect.height + units.gridUnit

	LayoutMirroring.enabled: Qt.application.layoutDirection === Qt.RightToLeft
	LayoutMirroring.childrenInherit: true

	property var dataSource: timeModel.dataSource
	readonly property string timezoneTimeFormat: Qt.locale().timeFormat(Locale.ShortFormat)

	function timeForZone(zone) {
		var compactRepresentationItem = plasmoid.compactRepresentationItem
		if (!compactRepresentationItem) {
			return ""
		}

		// get the time for the given timezone from the dataengine
		var now = dataSource.data[zone]["DateTime"]
		// get current UTC time
		var msUTC = now.getTime() + (now.getTimezoneOffset() * 60000)
		// add the dataengine TZ offset to it
		var dateTime = new Date(msUTC + (dataSource.data[zone]["Offset"] * 1000))

		var formattedTime = Qt.formatTime(dateTime, timezoneTimeFormat)

		if (dateTime.getDay() != dataSource.data["Local"]["DateTime"].getDay()) {
			formattedTime += " (" + Qt.formatDate(dateTime, Locale.ShortFormat) + ")"
		}

		return formattedTime
	}

	function nameForZone(zone) {
		if (plasmoid.configuration.displayTimezoneAsCode) {
			return dataSource.data[zone]["Timezone Abbreviation"]
		} else {
			return DigitalClock.TimezonesI18n.i18nCity(dataSource.data[zone]["Timezone City"])
		}
	}

	ColumnLayout {
		id: columnLayout
		anchors {
			left: parent.left
			top: parent.top
			margins: units.gridUnit / 2
		}
		spacing: units.largeSpacing

		RowLayout {
			spacing: units.largeSpacing

			PlasmaCore.IconItem {
				id: tooltipIcon
				source: "preferences-system-time"
				Layout.alignment: Qt.AlignTop
				visible: true
				implicitWidth: units.iconSizes.medium
				Layout.preferredWidth: implicitWidth
				Layout.preferredHeight: implicitWidth
			}

			ColumnLayout {
				spacing: 0

				PlasmaExtras.Heading {
					id: tooltipMaintext
					level: 3
					Layout.minimumWidth: Math.min(implicitWidth, preferredTextWidth)
					Layout.maximumWidth: preferredTextWidth
					elide: Text.ElideRight
					text: Qt.formatTime(timeModel.currentTime, Qt.locale().timeFormat(Locale.LongFormat))
				}

				PlasmaComponents3.Label {
					id: tooltipSubtext
					Layout.minimumWidth: Math.min(implicitWidth, preferredTextWidth)
					Layout.maximumWidth: preferredTextWidth
					text: Qt.formatDate(timeModel.currentTime, Qt.locale().dateFormat(Locale.LongFormat))
					opacity: 0.6
				}
			}
		}


		GridLayout {
			id: timezoneLayout
			Layout.minimumWidth: Math.min(implicitWidth, preferredTextWidth)
			Layout.maximumWidth: preferredTextWidth
			// Layout.maximumHeight: childrenRect.height // Causes binding loop
			columns: 2
			visible: timezoneRepeater.count > 0

			Repeater {
				id: timezoneRepeater
				model: {
					// The timezones need to be duplicated in the array
					// because we need their data twice - once for the name
					// and once for the time and the Repeater delegate cannot
					// be one Item with two Labels because that wouldn't work
					// in a grid then
					var timezones = []
					for (var i = 0; i < plasmoid.configuration.selectedTimeZones.length; i++) {
						var timezone = plasmoid.configuration.selectedTimeZones[i]
						if (timezone != 'Local') {
							timezones.push(timezone)
							timezones.push(timezone)
						}
					}

					return timezones
				}

				PlasmaComponents3.Label {
					id: timezone
					Layout.alignment: index % 2 === 0 ? Qt.AlignRight : Qt.AlignLeft

					wrapMode: Text.NoWrap
					text: index % 2 == 0 ? nameForZone(modelData) : timeForZone(modelData)
					font.weight: index % 2 == 0 ? Font.Bold : Font.Normal
					elide: Text.ElideNone
					opacity: 0.6
				}
			}
		}
	}
}
