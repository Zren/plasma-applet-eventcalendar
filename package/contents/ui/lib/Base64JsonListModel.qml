import QtQuick 2.0

ListModel {
	id: listModel
	property alias configKey: base64Json.configKey

	property int oldCount: count
	property QtObject base64Json: Base64Json {
		id: base64Json
		value: []
		onValueChanged: {
			listModel.clear()
			if (value !== null) {
				for (var i = 0; i < value.length; i++) {
					var item = value[i]
					listModel.append(item)
				}
			}
		}
	}

	function addItem(obj) {
		append(obj)
		base64Json.value.push(obj)
		serialize()
	}

	function removeIndex(index) {
		remove(index)
		base64Json.value.splice(index, 1)
		serialize()
	}

	function setItemProperty(index, key, value) {
		setProperty(index, key, value)
		base64Json.value[index][key] = value
		serialize()
	}

	function serialize() {
		if (throttle > 0) {
			serializeTimer.restart()
		} else {
			base64Json.serialize()
		}
	}

	property alias throttle: serializeTimer.interval
	property Timer serializeTimer: Timer {
		id: serializeTimer
		interval: 200
		onTriggered: {
			base64Json.serialize()
		}
	}
}
