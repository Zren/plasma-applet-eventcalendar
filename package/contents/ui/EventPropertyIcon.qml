import QtQuick 2.0
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore

ColumnLayout {
	id: eventDialogIcon
	Layout.fillHeight: true

	property alias source: iconItem.source
	property int size: units.iconSizes.smallMedium

	PlasmaCore.IconItem {
		id: iconItem
		Layout.alignment: Qt.AlignVCenter

		implicitWidth: eventDialogIcon.size
		implicitHeight: eventDialogIcon.size
	}
}
