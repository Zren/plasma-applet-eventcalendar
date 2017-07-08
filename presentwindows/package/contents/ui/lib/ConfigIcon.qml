import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0
import QtQuick.Dialogs 1.2

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.kquickcontrolsaddons 2.0 as KQuickAddons

import ".."

RowLayout {
	id: configIcon
	
	default property alias _contentChildren: content.data

	property string configKey: ''
	property alias value: textField.text
	readonly property string configValue: configKey ? plasmoid.configuration[configKey] : ""
	onConfigValueChanged: {
		if (!textField.focus && value != configValue) {
			value = configValue
		}
	}
	property int previewIconSize: units.iconSizes.medium
	property string defaultValue: "start-here-kde"

	// org.kde.plasma.kickoff
	Button {
		id: iconButton
		Layout.minimumWidth: previewFrame.width + units.smallSpacing * 2
		Layout.maximumWidth: Layout.minimumWidth
		Layout.minimumHeight: previewFrame.height + units.smallSpacing * 2
		Layout.maximumHeight: Layout.minimumWidth

		

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
			width: previewIconSize + fixedMargins.left + fixedMargins.right
			height: previewIconSize + fixedMargins.top + fixedMargins.bottom

			AppletIcon {
				anchors.centerIn: parent
				width: previewIconSize
				height: previewIconSize
				source: configIcon.value
			}
		}

		// QQC Menu can only be opened at cursor position, not a random one
		PlasmaComponents.ContextMenu {
			id: iconMenu
			visualParent: iconButton

			PlasmaComponents.MenuItem {
				text: i18ndc("plasma_applet_org.kde.plasma.kickoff", "@item:inmenu Open icon chooser dialog", "Choose...")
				icon: "document-open"
				onClicked: iconDialog.open()
			}
			PlasmaComponents.MenuItem {
				text: i18ndc("plasma_applet_org.kde.plasma.kickoff", "@item:inmenu Reset icon to default", "Clear Icon")
				icon: "edit-clear"
				onClicked: configIcon.value = defaultValue
			}
		}
	}

	ColumnLayout {
		id: content
		Layout.fillWidth: true

		RowLayout {
			TextField {
				id: textField
				Layout.fillWidth: true

				text: configIcon.configValue
				onTextChanged: serializeTimer.restart()

				ToolButton {
					iconName: "edit-clear"
					onClicked: configIcon.value = defaultValue

					anchors.top: parent.top
					anchors.right: parent.right
					anchors.bottom: parent.bottom

					width: height
				}
			}

			Button {
				iconName: "document-open"
				onClicked: iconDialog.open()
			}
		}

		// Workaround for crash when using default on a Layout.
		// https://bugreports.qt.io/browse/QTBUG-52490
		// Still affecting Qt 5.7.0
		Component.onDestruction: {
			while (data.length > 0) {
				data[data.length - 1].parent = configIcon;
			}
		}
	}

	KQuickAddons.IconDialog {
		id: iconDialog
		onIconNameChanged: configIcon.value = iconName
	}

	Timer { // throttle
		id: serializeTimer
		interval: 300
		onTriggered: plasmoid.configuration[configKey] = configIcon.value
	}
}
