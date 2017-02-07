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

	function setItemProperty(itemKey, key, val) {
		var item = value[itemKey] || {}
		item[key] = val
		value[itemKey] = item
		set(value)
		valueChanged()
	}

	function getItemProperty(itemKey, key, def) {
		var item = value[itemKey] || {}
		return typeof item[key] === undefined ? item[key] : def
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
