import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1
import QtQuick.Window 2.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

MouseArea {
	hoverEnabled: true
	z: 1
	// clip: true
	width: open ? 200 : 60
	property bool open: false

	onOpenChanged: {
		if (open) {
			forceActiveFocus()
		}
	}
}
