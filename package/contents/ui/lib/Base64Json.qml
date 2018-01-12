import QtQuick 2.0

QtObject {
	property string configKey
	readonly property string configValue: plasmoid.configuration[configKey]
	property var value: null

	onConfigValueChanged: deserialize()

	function deserialize() {
		var s = JSON.parse(Qt.atob(configValue))
		value = s
	}

	function serialize() {
		var v = Qt.btoa(JSON.stringify(value))
		plasmoid.configuration[configKey] = v
	}
}
