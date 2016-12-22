import QtQuick 2.2
import QtQuick.Window 2.1
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2
import QtQuick.Layouts 1.0
import QtQuick.Dialogs 1.0

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

import "./config"

Window {
	width: 600
	height: 600
	title: i18n('%1 - Tiled Menu', model.favoriteId)

	property var item
	property var model
	property var config

	// ConfigPage {
		RowLayout {
			anchors.fill: parent
			ColumnLayout {
				Layout.alignment: Qt.AlignTop
				// Layout.fillWidth: true
				ExclusiveGroup { id: tileDataSizeGroup }
				ConfigSection {
					label: i18n("Size")

					PlasmaComponents.RadioButton {
						exclusiveGroup: tileDataSizeGroup
						text: i18n("Small")
						checked: item.tileDataSize === 'small'
						onClicked: item.tileData.size = 'small'
					}
					PlasmaComponents.RadioButton {
						exclusiveGroup: tileDataSizeGroup
						text: i18n("Medium")
						checked: item.tileDataSize === 'medium'
						onClicked: item.tileData.size = 'medium'
					}
				}
				ConfigSection {
					label: i18n("Label")

					PlasmaComponents.TextField {
						Layout.fillWidth: true
						placeholderText: model.display
						onTextChanged: {
							console.log('tileData', item.tileData, item.tileDataLabel)
							config.tileData.setItemProperty(model.favoriteId, 'label', text)
							// item.tileDataLabel = text
							// if (!tileData) {
							// 	config.tileData.value[model.favoriteId] = {}
							// }
							// config.tileData.value[model.favoriteId].label = text
						}
					}
				}
			}
		}
		
	// }

	
}
