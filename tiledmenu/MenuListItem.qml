import QtQuick 2.0
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

PlasmaComponents.ToolButton {
	id: itemDelegate
	// https://github.com/KDE/plasma-desktop/blob/a84f78f7df0fcee4153b7ef515e89d443592fd62/applets/kicker/plugin/abstractmodel.cpp#L33
	// model.display
	// model.description
	// model.url

	// width: itemDelegate.width
	width: parent.width
	height: row.height

	property var runner: runnerModel.modelForRow(model.runnerIndex)
	property string description: model.url ? model.description : '' // 
	property string secondRowText: model.url ? '' : model.description
	property bool secondRowVisible: secondRowText
	Component.onCompleted: {
		// console.log('runnerModel[' + index1 + '][' + index + ']', model, model.display)
	}
	
	RowLayout { // ItemListDelegate
		id: row
		width: parent.width
		// height: 36 // 2 lines
		height: index == 0 ? 64 : 36

		Item {
			height: parent.height
			width: parent.height
			// width: itemIcon.width
			Layout.fillHeight: true

			PlasmaCore.IconItem {
				id: itemIcon
				anchors.centerIn: parent
				height: parent.height
				width: height
				// height: 48
				

				// height: parent.height
				// width: height

				// visible: iconsEnabled

				animated: false
				// usesPlasmaTheme: false
				// source: model.decoration
				source: runner && runner.data(runner.index(model.runnerItemIndex, 0), Qt.DecorationRole)
			}
		}

		ColumnLayout {
			Layout.fillWidth: true
			// Layout.fillHeight: true
			anchors.verticalCenter: parent.verticalCenter
			spacing: 0

			RowLayout {
				Layout.fillWidth: true
				// height: itemLabel.height

				PlasmaComponents.Label {
					id: itemLabel
					text: model.name
					maximumLineCount: 1
					// elide: Text.ElideMiddle
					height: implicitHeight
				}

				PlasmaComponents.Label {
					Layout.fillWidth: true
					text: !itemDelegate.secondRowVisible ? itemDelegate.description : ''
					color: "#888"
					maximumLineCount: 1
					elide: Text.ElideRight
					height: implicitHeight // ElideRight causes some top padding for some reason
				}
			}

			PlasmaComponents.Label {
				visible: itemDelegate.secondRowVisible
				Layout.fillWidth: true
				// Layout.fillHeight: true
				text: itemDelegate.secondRowText
				color: "#888"
				maximumLineCount: 1
				elide: Text.ElideMiddle
				height: implicitHeight
			}
		}
	}

	onClicked: {
		runner.trigger(model.runnerItemIndex, "", null);
		widget.expanded = false;
	}
}