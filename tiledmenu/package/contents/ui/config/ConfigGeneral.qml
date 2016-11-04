import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kquickcontrolsaddons 2.0 as KQuickAddons

import ".."

Item {
	id: page

	property alias cfg_icon: plasmoid.configuration.icon

	GroupBox {
		Layout.fillWidth: true

		ColumnLayout {
			id: content
			Layout.fillWidth: true


			// org.kde.plasma.kickoff
			Button {
				id: iconButton
				Layout.minimumWidth: previewFrame.width + units.smallSpacing * 2
				Layout.maximumWidth: Layout.minimumWidth
				Layout.minimumHeight: previewFrame.height + units.smallSpacing * 2
				Layout.maximumHeight: Layout.minimumWidth

				KQuickAddons.IconDialog {
					id: iconDialog
					onIconNameChanged: cfg_icon = iconName || "start-here-kde" // TODO use actual default
				}

				// just to provide some visual feedback, cannot have checked without checkable enabled
				checkable: true
				onClicked: {
					checked = Qt.binding(function() { // never actually allow it being checked
						return iconMenu.status === PlasmaComponents.DialogStatus.Open
					})

					iconMenu.open(0, height)
				}

				PlasmaCore.FrameSvgItem {
					id: previewFrame
					anchors.centerIn: parent
					imagePath: plasmoid.location === PlasmaCore.Types.Vertical || plasmoid.location === PlasmaCore.Types.Horizontal
							 ? "widgets/panel-background" : "widgets/background"
					width: units.iconSizes.large + fixedMargins.left + fixedMargins.right
					height: units.iconSizes.large + fixedMargins.top + fixedMargins.bottom

					PlasmaCore.IconItem {
						anchors.centerIn: parent
						width: units.iconSizes.large
						height: width
						source: cfg_icon
					}
				}

				// QQC Menu can only be opened at cursor position, not a random one
				PlasmaComponents.ContextMenu {
					id: iconMenu
					visualParent: iconButton

					PlasmaComponents.MenuItem {
						text: i18nc("@item:inmenu Open icon chooser dialog", "Choose...")
						icon: "document-open-folder"
						onClicked: iconDialog.open()
					}
					PlasmaComponents.MenuItem {
						text: i18nc("@item:inmenu Reset icon to default", "Clear Icon")
						icon: "edit-clear"
						onClicked: cfg_icon = "start-here-kde" // TODO reset to actual default
					}
				}
			}
		}
	}

}
