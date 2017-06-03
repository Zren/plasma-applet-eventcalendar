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
	
	AppObject {
		id: appObj
	}
	property alias tile: appObj.tile

	function resetView() {
		tile = null
	}

	function resetTile() {
		delete appObj.tile.showIcon
		delete appObj.tile.showLabel
		delete appObj.tile.label
		delete appObj.tile.label
		delete appObj.tile.icon
		delete appObj.tile.backgroundColor
		delete appObj.tile.backgroundImage
		appObj.tileChanged()
		favouritesView.tileModelChanged()
	}



	RowLayout {
		PlasmaExtras.Heading {
			Layout.fillWidth: true
			level: 2
			text: i18n("Edit Tile")
		}

		PlasmaComponents.Button {
			text: i18n("Reset Tile")
			onClicked: resetTile()
		}

		PlasmaComponents.Button {
			text: i18n("Close")
			onClicked: {
				tileEditorView.close() // Defined in SearchView.qml
			}
		}
	}

	TileEditorField {
		title: i18n("Url")
		key: 'url'
	}

	TileEditorField {
		id: labelField
		title: i18n("Label")
		placeholderText: appObj.appLabel
		key: 'label'
		checkedKey: 'showLabel'
	}

	TileEditorField {
		id: iconField
		title: i18n("Icon")
		// placeholderText: appObj.appIcon ? appObj.appIcon.toString() : ''
		key: 'icon'
		checkedKey: 'showIcon'
	}

	TileEditorField {
		id: backgroundImageField
		title: i18n("Background Image")
		key: 'backgroundImage'

		PlasmaComponents.Button {
			iconName: 'document-open'
			onClicked: imagePicker.open()

			FileDialog {
				id: imagePicker

				title: i18n("Choose an image")

				selectFolder: false
				selectMultiple: false

				nameFilters: [ i18n("Image Files (*.png *.jpg *.jpeg *.bmp *.svg *.svgz)") ]

				onFileUrlChanged: {
					backgroundImageField.text = fileUrl
					if (fileUrl) {
						labelField.checked = false
						iconField.checked = false
					}
				}
			}
		}
	}

	TileEditorColorField {
		title: i18n("Background Color")
		placeholderText: config.defaultTileColor
		key: 'backgroundColor'
	}

	TileEditorRectField {
		title: i18n("Position / Size")
	}

	Item { // Consume the extra space below
		Layout.fillHeight: true
	}

}
