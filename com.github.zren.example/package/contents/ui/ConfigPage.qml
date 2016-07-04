import QtQuick 2.0
import QtQuick.Layouts 1.0

ColumnLayout {
    Layout.fillWidth: true
    default property alias _contentChildren: content.data

    ColumnLayout {
        id: content
        Layout.fillWidth: true
        Layout.alignment: Qt.AlignTop

    }
}
