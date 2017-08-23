import QtQuick 2.0

QtObject {
	readonly property color defaultNormalColor: theme.textColor
	readonly property color normalColor: plasmoid.configuration.normalColor || defaultNormalColor
	
	readonly property color defaultChargingColor: '#1e1'
	readonly property color chargingColor: plasmoid.configuration.chargingColor || defaultChargingColor
	
	readonly property color defaultLowBatteryColor: '#e33'
	readonly property color lowBatteryColor: plasmoid.configuration.lowBatteryColor || defaultLowBatteryColor

	readonly property bool timeLeftUseLocaleFormat: plasmoid.configuration.timeLeftFormat != '69m'
}
