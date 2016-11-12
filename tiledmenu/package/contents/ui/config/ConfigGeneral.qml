import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0
import QtQuick.Dialogs 1.2

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kquickcontrolsaddons 2.0 as KQuickAddons
import org.kde.plasma.private.kicker 0.1 as Kicker

import ".."

ConfigPage {
	id: page

	property alias cfg_icon: icon.text

	AppletConfig {
		id: config
	}


	ConfigSection {
		label: i18n("Panel Icon")

		RowLayout {
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

			TextField {
				id: icon
				Layout.fillWidth: true
			}

			// org.kde.plasma.kicker
			Button {
				iconName: "document-open"

				enabled: useCustomButtonImage.checked

				onClicked: {
					imagePicker.folder = systemSettings.picturesLocation();
					imagePicker.open();
				}

				Kicker.SystemSettings {
					id: systemSettings
				}
			}

			FileDialog {
				id: imagePicker

				title: i18n("Choose an image")

				selectFolder: false
				selectMultiple: false

				nameFilters: [ i18n("Image Files (*.png *.jpg *.jpeg *.bmp *.svg *.svgz)") ]

				onFileUrlChanged: {
					cfg_icon = fileUrl
				}
			}
		}
	}

	ExclusiveGroup { id: tilesThemeGroup }
	ConfigSection {
		label: i18n("Tiles")

		RadioButton {
			text: i18n('Desktop Theme (%1)', theme.themeName)
			exclusiveGroup: tilesThemeGroup
			checked: false
			enabled: false
		}
		RowLayout {
			RadioButton {
				text: i18n('Custom Color')
				exclusiveGroup: tilesThemeGroup
				checked: true
			}
			ConfigColor {
				label: ""
				configKey: 'defaultTileColor'
			}
		}
		
	}

	ExclusiveGroup { id: sidebarThemeGroup }
	ConfigSection {
		label: i18n("Sidebar")

		RadioButton {
			text: i18n('Desktop Theme (%1)', theme.themeName)
			exclusiveGroup: sidebarThemeGroup
			checked: false
			enabled: false
		}
		RowLayout {
			RadioButton {
				text: i18n('Custom Color')
				exclusiveGroup: sidebarThemeGroup
				checked: true
			}
			ConfigColor {
				label: ""
				configKey: 'sidebarBackgroundColor'
			}
		}
		
	}

	ExclusiveGroup { id: searchBoxThemeGroup }
	ConfigSection {
		label: i18n("Search Box")
		
		RadioButton {
			text: i18n('Desktop Theme (%1)', theme.themeName)
			exclusiveGroup: searchBoxThemeGroup
			checked: plasmoid.configuration.searchFieldFollowsTheme
			onClicked: plasmoid.configuration.searchFieldFollowsTheme = true
		}
		RadioButton {
			text: i18n('Windows (White)')
			exclusiveGroup: searchBoxThemeGroup
			checked: !plasmoid.configuration.searchFieldFollowsTheme
			onClicked: plasmoid.configuration.searchFieldFollowsTheme = false
		}
	}
}
