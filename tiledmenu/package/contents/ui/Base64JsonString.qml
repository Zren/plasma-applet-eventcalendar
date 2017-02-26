import QtQuick 2.0

QtObject {
	property string configKey
	property string configValue: plasmoid.configuration[configKey]
	property variant value: { return {} }
	property variant defaultValue: { return {} }
	property bool writing: false

	Component.onCompleted: {
		load()
	}

	onConfigValueChanged: load()

	function getBase64Json(key, defaultValue) {
		var val = plasmoid.configuration[key]
		if (val === '') {
			return defaultValue
		}
		val = Qt.atob(val) // decode base64
		val = JSON.parse(val)
		return val
	}

	function setBase64Json(key, data) {
		var val = JSON.stringify(data)
		val = Qt.btoa(val)
		plasmoid.configuration[key] = val
	}

	function set(obj) {
		writing = true
		setBase64Json(configKey, obj)
		writing = false
	}

	function setItemProperty(key1, key2, val) {
		var item = value[key1] || {}
		item[key2] = val
		value[key1] = item
		set(value)
		valueChanged()
	}

	function getItemProperty(key1, key2, def) {
		var item = value[key1] || {}
		return typeof item[key2] !== "undefined" ? item[key2] : def
	}

	function load() {
		console.log('load')
		console.log('configKey', configKey)
		console.log('plasmoid.configuration[key]', plasmoid.configuration[configKey])
		value = getBase64Json(configKey, defaultValue)
	}

	onValueChanged: {
		console.log('onValueChanged', configKey, value)
	}
}
