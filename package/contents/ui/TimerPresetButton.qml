import QtQuick 2.0
import QtQuick.Layouts 1.0
import org.kde.plasma.components 2.0 as PlasmaComponents

// minimumWidth is from PlasmaComponents2's ButtonStyle:
// https://github.com/KDE/plasma-framework/blame/master/src/declarativeimports/plasmastyle/ButtonStyle.qml#L37

PlasmaComponents.Button {
	// Layout.fillWidth: true
	Layout.minimumWidth: minimumWidth
	Layout.preferredWidth: appletConfig.timerButtonWidth
}
