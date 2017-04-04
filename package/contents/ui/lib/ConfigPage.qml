import QtQuick 2.0
import QtQuick.Layouts 1.0

ColumnLayout {
	id: page
	Layout.fillWidth: true
	default property alias _contentChildren: content.data

	ColumnLayout {
		id: content
		Layout.fillWidth: true
		Layout.alignment: Qt.AlignTop

		// Workaround for crash when using default on a Layout.
		// https://bugreports.qt.io/browse/QTBUG-52490
		// Still affecting Qt 5.7.0
		Component.onDestruction: {
			while (children.length > 0) {
				children[children.length - 1].parent = page;
			}
		}
	}

	property alias showAppletVersion: appletVersionLoader.active
	Loader {
		id: appletVersionLoader
		active: false
		visible: active
		source: "AppletVersion.qml"
		anchors.right: parent.right
		anchors.bottom: parent.top
	}
}
