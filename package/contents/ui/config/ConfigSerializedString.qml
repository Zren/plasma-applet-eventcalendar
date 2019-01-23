import QtQuick 2.0

QtObject {
	id: obj
	property string configKey: ''
	readonly property string configValue: configKey ? plasmoid.configuration[configKey] : ''
	property var value: null
	property var defaultValue: ({}) // Empty Map

	function serialize() {
		plasmoid.configuration[configKey] = Qt.btoa(JSON.stringify(value))
	}

	function deserialize() {
		value = configValue ? JSON.parse(Qt.atob(configValue)) : defaultValue
	}

	onConfigKeyChanged: deserialize()
	onConfigValueChanged: deserialize()
	onValueChanged: {
		if (value === null) {
			return // 99% of the time this is unintended
		}
		serialize()
	}
}
