import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0

GroupBox {
	id: control
	Layout.fillWidth: true
	default property alias _contentChildren: content.children
	property string label

	ColumnLayout {
		id: content
		Layout.fillWidth: true

		Text {
			visible: control.label
			text: control.label
			font.bold: true
		}
	}
}
