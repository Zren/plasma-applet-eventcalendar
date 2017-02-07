import QtQuick 2.2
import QtQuick.Window 2.1
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.0
import QtQuick.Dialogs 1.0

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

import "./config"

ColumnLayout {
	id: tileEditorView

	// Layout.fillWidth: true
	// Layout.fillHeight: true
	width: 200
	height: 200
	Layout.alignment: Qt.AlignTop
	
	property string favoriteId: ''
	property var item: null

	function reset() {
		favoriteId = ''
		item = null
	}

	function set(key, val) {
		console.log('set', favoriteId, key, val)
		if (!favoriteId) return;
		config.tileData.setItemProperty(favoriteId, key, val)
	}

	function get(key, def) {
		if (!favoriteId) {
			return '';
		} else {
			return config.tileData.getItemProperty(favoriteId, key, def)
		}
	}

	readonly property string tileDataSize: item ? item.tileDataSize : 'medium'
	function setTileDataSize(size) { set('size', size) }
	onTileDataSizeChanged: console.log('tileDataSize', tileDataSize)

	readonly property string tileDataLabel: item ? item.tileDataLabel : ''
	function setTileDataLabel(label) { set('label', label) }

	readonly property string modelLabel: item ? item.modelLabel : 'asdasdasdasd'


	RowLayout {

		PlasmaExtras.Heading {
			Layout.fillWidth: true
			level: 2
			text: favoriteId
		}

		PlasmaComponents.Button {
			text: i18n("Save")
			onClicked: {
				tileEditorView.close() // Defined in SearchView.qml
			}
		}
	}

	ExclusiveGroup { id: tileDataSizeGroup }
	GroupBox {
		title: i18n("Size")
		Layout.fillWidth: true

		ColumnLayout {
			anchors.fill: parent

			PlasmaComponents.RadioButton {
				id: smallSizeButton
				exclusiveGroup: tileDataSizeGroup
				text: i18n("Small")
				onClicked: setTileDataSize('small')
				Connections { 
					target: tileEditorView
					onFavoriteIdChanged: smallSizeButton.checked = Qt.binding(function(){ return tileDataSize === 'small' })
				}
			}
			PlasmaComponents.RadioButton {
				id: mediumSizeButton
				exclusiveGroup: tileDataSizeGroup
				text: i18n("Medium")
				onClicked: setTileDataSize('medium')
				Connections {
					target: tileEditorView
					onFavoriteIdChanged: mediumSizeButton.checked = Qt.binding(function(){ return tileDataSize === 'medium' })
				}
			}
		}
	}

	GroupBox {
		title: i18n("Label")
		Layout.fillWidth: true

		ColumnLayout {
			anchors.fill: parent

			PlasmaComponents.TextField {
				id: labelTextField
				Layout.fillWidth: true
				placeholderText: modelLabel
				onTextChanged: setTileDataLabel(text)

				Connections {
					target: tileEditorView
					onFavoriteIdChanged: labelTextField.text = get('label', '')
				}
			}
		}
	}

	Item { // Consume the extra space below
		Layout.fillHeight: true
	}

}
