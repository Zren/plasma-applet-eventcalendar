import QtQuick 2.0
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

GridLayout {
	columns: 1
	rowSpacing: 4
	property alias title: label.text

	PlasmaComponents.Label {
		id: label
		visible: !!text
		text: title
		height: implicitHeight
	}
}