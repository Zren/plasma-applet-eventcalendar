// Version 4

import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Controls.Styles 1.0
import QtQuick.Layouts 1.0

ColumnLayout {
	id: page

	SystemPalette {
		id: syspal
	}

	Component {
		id: textFieldStyle
		TextFieldStyle {
			// textColor: syspal.text

			background: Rectangle {
				radius: 2
				color: control.activeFocus ? syspal.base : "transparent"
				border.color: control.activeFocus ? syspal.highlight : "transparent"
				border.width: 1
			}
		}
	}

	ScrollView {
		Layout.fillWidth: true
		Layout.fillHeight: true

		ListView {
			id: configTable

			Layout.fillWidth: true
			Layout.fillHeight: true

			spacing: units.smallSpacing

			model: []
			cacheBuffer: 100000

			Component {
				id: boolControl
				CheckBox {
					checked: modelValue
					text: modelValue
					onClicked: plasmoid.configuration[modelKey] = !modelValue
				}
			}

			Component {
				id: numberControl
				SpinBox {
					value: modelValue
					property bool isInteger: modelConfigType === 'UInt' || modelConfigType === 'int'
					decimals: isInteger ? 0 : 3
					maximumValue: 2147483647
					Component.onCompleted: {
						valueChanged.connect(function() {
							plasmoid.configuration[modelKey] = value
						})
					}
				}
			}

			Component {
				id: stringListControl
				TextArea {
					text: '' + modelValue
					readOnly: true
					implicitHeight: contentHeight + font.pixelSize
					wrapMode: TextEdit.Wrap
				}
			}

			Component {
				id: stringControl
				TextArea {
					text: modelValue
					// readOnly: true
					implicitHeight: contentHeight + font.pixelSize
					wrapMode: TextEdit.Wrap
					Component.onCompleted: {
						textChanged.connect(function() {
							plasmoid.configuration[modelKey] = text
						})
					}
				}
			}

			Component {
				id: base64jsonControl
				TextArea {
					text: {
						if (modelValue) {
							var data = JSON.parse(Qt.atob(modelValue))
							return JSON.stringify(data, null, '  ')
						} else {
							return ''
						}
					}
					readOnly: true
					implicitHeight: contentHeight + font.pixelSize
					wrapMode: TextEdit.Wrap
				}
			}

			delegate: RowLayout {
				width: parent.width

				property bool isDefault: ('' + model.value) === model.defaultValue

				TextField {
					Layout.alignment: Qt.AlignTop | Qt.AlignLeft
					// Layout.fillWidth: true
					text: model.key
					readOnly: true
					style: textFieldStyle
					Layout.preferredWidth: 200 * units.devicePixelRatio
					font.bold: !isDefault
				}
				TextField {
					Layout.alignment: Qt.AlignTop | Qt.AlignLeft
					text: model.stringType || model.configType || model.valueType
					readOnly: true
					style: textFieldStyle
					Layout.preferredWidth: 80 * units.devicePixelRatio
				}
				Loader {
					id: valueControlLoader
					Layout.fillWidth: true
					property var modelKey: model.key
					property var modelValueType: model.valueType
					property var modelValue: model.value
					property var modelConfigType: model.configType
					sourceComponent: {
						if (model.valueType === 'boolean') {
							return boolControl
						} else if (model.valueType === 'number') {
							return numberControl
						} else if (model.valueType === 'object') { // StringList
							return stringListControl
						} else { // string
							if (model.stringType === 'base64json') {
								return base64jsonControl
							} else {
								return stringControl
							}
						}
						
					}
				}
				
			}
		}
	}

	ListModel {
		id: configDefaults

		property bool loading: false
		property bool error: false
		property string source: plasmoid.file("", "config/main.xml")

		signal updated()

		// https://stackoverflow.com/a/29881855/947742
		function fetch() {
			var doc = new XMLHttpRequest()
			doc.onreadystatechange = function() {
				error = false
				if (doc.readyState === XMLHttpRequest.DONE) {
					if (doc.status != 200) {
						error = true
					} else {
						var rootNode = doc.responseXML.documentElement
						parse(rootNode)
					}
					loading = false
					updated()
				}
			}
			loading = true
			doc.open("GET", source)
			doc.send()
		}

		function findNode(parentNode, tagName) {
			for (var i = 0; i < parentNode.childNodes.length; i++) {
				var node = parentNode.childNodes[i]
				if (node.nodeName === tagName) {
					return node
				}
			}
		}

		function findAll(parentNode, tagName, callback) {
			for (var i = 0; i < parentNode.childNodes.length; i++) {
				var node = parentNode.childNodes[i]
				if (node.nodeName === tagName) {
					callback(node)
				}
			}
		}

		function getText(parentNode) {
			for (var i = 0; i < parentNode.childNodes.length; i++) {
				var node = parentNode.childNodes[i]
				if (node.nodeName === '#text') {
					return node.nodeValue
				}
			}
		}

		// https://doc.qt.io/qt-5/qdomnode.html
		function parse(rootNode) {
			clear()
			findAll(rootNode, 'group', function(group) {
				findAll(group, 'entry', function(entry) {
					var key = entry.attributes['name'].nodeValue
					var valueType = entry.attributes['type'].nodeValue
					var value = getText(findNode(entry, 'default'))

					var stringType = entry.attributes['stringType']
					if (stringType) {
						stringType = stringType.nodeValue
					} else {
						stringType = null
					}

					configDefaults.append({
						key: key,
						valueType: valueType,
						value: value,
						stringType: stringType
					})
				})
			})
		}

		Component.onCompleted: fetch()
	}


	// plasmoid.configuration is a KDeclarative::ConfigPropertyMap which inherits QQmlPropertyMap
	// https://github.com/KDE/kdeclarative/blob/master/src/kdeclarative/configpropertymap.h
	// https://doc.qt.io/qt-5/qqmlpropertymap.html
	ListModel {
		id: configTableModel
		dynamicRoles: true

		property var keys: []

		Component.onCompleted: {
			keys = plasmoid.configuration.keys()
			// console.log(JSON.stringify(keys, null, '\t'))
			for (var i = 0; i < keys.length; i++) {
				var key = keys[i]
				if (key === 'minimumWidth') {
					break // Where is this defined?! Exit loop when we reach this key.
				}

				var value = plasmoid.configuration[key]
				
				configTableModel.append({
					key: key,
					valueType: typeof value,
					value: value,
					configType: null,
					stringType: null,
					defaultValue: null,
				})
			}
			configTable.model = configTableModel
		}
	}

	Connections {
		target: configDefaults
		onUpdated: {
			var keys = configTableModel.keys
			// Assume the default main.xml's order and plasmoid.configuration is the same (we probably shouldn't).
			for (var i = 0; i < keys.length; i++) {
				var key = keys[i]
				var value = plasmoid.configuration[key]
				var valueStr = '' + value
				var node = configDefaults.get(i)
				if (!node) {
					console.log('configDefaults doesn\'t conain an entry for plasmoid.configuration.' + key)
					continue
				}
				var configType = node.valueType
				var stringType = node.stringType
				var defaultValue = node.value

				configTableModel.setProperty(i, 'configType', configType)
				configTableModel.setProperty(i, 'stringType', stringType)
				configTableModel.setProperty(i, 'defaultValue', defaultValue)
			}
		}
	}

	Connections {
		target: plasmoid.configuration
		onValueChanged: {
			var keyIndex = configTableModel.keys.indexOf(key)
			if (keyIndex >= 0) {
				configTableModel.setProperty(keyIndex, 'value', value)
			}
		}
	}
}
