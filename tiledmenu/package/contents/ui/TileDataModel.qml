import QtQuick 2.0

Item {
	id: tileData
	property string configKey: 'tileData'
	property variant value: { return {} }
	property variant defaultValue: { return {} }
	property bool writing: false

	function set(obj) {
		writing = true
		setBase64Json(configKey, obj)
		writing = false
	}

	function load() {
		// console.log('plasmoid.configuration[key]', plasmoid.configuration[configKey])
		value = getBase64Json(configKey, defaultValue)
		// console.log(configKey, 'load()', value, defaultValue)
		// console.log('discover', getTileData("org.kde.dolphin.desktop").label)
		// console.log('discover', value["org.kde.dolphin.desktop"].label)
	}

	Connections {
		target: plasmoid.configuration
		onTileDataChanged: {
			tileData.load()
		}
	}

	Component.onCompleted: {
		// console.log('tileData.value', value)
		// console.log('tileData.defaultValue', defaultValue)
		// console.log('plasmoid.configuration[key]', plasmoid.configuration[configKey])
		tileData.load()
	}

	// function getTileData(url) {
	// 	// console.log('getTileData', url.toString())
	// 	// console.log('getTileData', url, value[url.toString()])
	// 	var tile = value[url] || {}
	// 	tile.x = tile.x || -1
	// 	tile.y = tile.y || -1
	// 	tile.size = tile.size || "2x2"
	// 	tile.label = tile.label || ""
	// 	return tile
	// }

	function setItemProperty(itemKey, key, value) {
		var item = value[itemKey] || {}
		item[key] = value
		value[itemKey] = item
		set(value)
		valueChanged()
	}
}
