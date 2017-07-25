import QtQuick 2.0

ListModel {
	id: listModel
	property alias configKey: base64Json.configKey

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
		base64Json.serialize()
	}

	function removeIndex(index) {
		remove(index)
		base64Json.value.splice(index, 1)
		base64Json.serialize()
	}
	
}
