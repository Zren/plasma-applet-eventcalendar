import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1
import QtQuick.Window 2.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

MouseArea {
	property alias searchView: searchView
	property alias tileEditorView: searchView.tileEditorView
	property alias favouritesView: favouritesView

	RowLayout {
		anchors.fill: parent
		spacing: 0

		SearchView {
			id: searchView
			Layout.minimumWidth: config.leftSectionWidth
			Layout.maximumWidth: config.leftSectionWidth
			Layout.fillHeight: true
		}

		TileGrid {
			id: favouritesView
			Layout.fillWidth: true
			Layout.fillHeight: true

			cellSize: config.cellSize
			cellMargin: config.cellMargin
			cellPushedMargin: config.cellPushedMargin

			tileModel: config.tileModel.value

			onEditTile: tileEditorView.open(tile)
		}
		
	}

	MouseArea {
		anchors.top: parent.top
		anchors.right: parent.right
		width: units.largeSpacing
		height: units.largeSpacing
		cursorShape: Qt.WhatsThisCursor

		PlasmaCore.ToolTipArea {
			anchors.fill: parent
			icon: "help-hint"
			mainText: i18n("Resize?")
			subText: i18n("Alt + Right Click to resize the menu.")
		}
	}

	onClicked: searchView.searchField.forceActiveFocus()
}
