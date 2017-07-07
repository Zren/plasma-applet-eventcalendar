import QtQuick 2.0
import QtQuick.Controls 1.2
import QtQuick.Layouts 1.0

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

// Origionally from digitalclock's configTimeZones.qml
// Recoloured with Bootstrap color scheme
Rectangle {
    id: messageWidget

    anchors {
        left: parent.left
        right: parent.right
        margins: 1
    }

    property alias text: label.text
    property alias wrapMode: label.wrapMode
    property alias closeButtonVisible: closeButton.visible

    property int messageType: warning
    property int positive: 0
    property int information: 1
    property int warning: 2
    property int error: 3

    visible: false
    clip: true
    height: 0
    radius: 5
    border.width: 1

    property var icon: {
        if (messageType == information) {
            return "dialog-information"
        } else if (messageType == warning) {
            return "dialog-warning"
        } else if (messageType == error) {
            return "dialog-error"
        } else { // positive
            return "dialog-ok"
        }
    }

    property color gradBaseColor: {
        if (messageType == information) {
            // return theme.highlightColor
            return "#d9edf7" // Bootstrap
        } else if (messageType == warning) {
            // return Qt.rgba(176/255, 128/255, 0, 1) // KMessageWidget
            // return "#EAC360" // DigitalClock
            return "#fcf8e3" // Bootstrap
        } else if (messageType == error) {
            // return Qt.rgba(191/255, 3/255, 3/255, 1)
            return "#f2dede" // Bootstrap
        } else { // positive
            // return Qt.rgba(0, 110/255, 40/255, 1)
            return "#dff0d8" // Bootstrap
        }
    }

    border.color: {
        if (messageType == information) {
            // return theme.highlightColor
            return "#bcdff1" // Bootstrap
        } else if (messageType == warning) {
            // return "#79735B" // DigitalClock
            return "#faf2cc" // Bootstrap
        } else if (messageType == error) {
            return "#ebcccc" // Bootstrap
        } else { // positive
            return "#d0e9c6" // Bootstrap
        }
    }

    property color labelColor: {
        // return PlasmaCore.ColorScope.textColor
        if (messageType == information) {
            return "#31708f" // Bootstrap
        } else if (messageType == warning) {
            return "#8a6d3b" // Bootstrap
        } else if (messageType == error) {
            return "#a94442" // Bootstrap
        } else { // positive
            return "#3c763d" // Bootstrap
        }
    }

    function show(message, messageType) {
        if (typeof messageType !== "undefined") {
            messageWidget.messageType = messageType
        }
        text = message
        visible = true
    }

    function success(message) {
        show(message, positive)
    }

    function info(message) {
        show(message, information)
    }

    function warn(message) {
        show(message, warning)
    }

    function err(message) {
        show(message, error)
    }

    gradient: Gradient {
        GradientStop { position: 0.0; color: Qt.lighter(messageWidget.gradBaseColor, 1.1) }
        GradientStop { position: 0.1; color: messageWidget.gradBaseColor }
        GradientStop { position: 1.0; color: Qt.darker(messageWidget.gradBaseColor, 1.1) }
    }

    Layout.minimumHeight: 0
    Layout.preferredHeight: Layout.minimumHeight
    readonly property int expandedHeight: label.implicitHeight + (2 * units.largeSpacing)
    Behavior on visible {
        ParallelAnimation {
            PropertyAnimation {
                target: messageWidget
                property: "opacity"
                to: messageWidget.visible ? 0 : 1.0
                easing.type: Easing.Linear
            }
            PropertyAnimation {
                target: messageWidget
                property: "Layout.minimumHeight"
                to: messageWidget.visible ? 0 : messageWidget.expandedHeight
                easing.type: Easing.Linear
            }
            PropertyAnimation {
                target: messageWidget
                property: "Layout.preferredHeight"
                to: messageWidget.visible ? 0 : messageWidget.expandedHeight
                easing.type: Easing.Linear
            }
        }
    }

    RowLayout {
        anchors.fill: parent
        anchors.margins: units.largeSpacing
        anchors.leftMargin: units.smallSpacing
        anchors.rightMargin: units.smallSpacing
        spacing: units.smallSpacing

        PlasmaCore.IconItem {
            id: iconItem
            anchors.verticalCenter: parent.verticalCenter
            Layout.preferredHeight: units.iconSizes.large
            Layout.preferredWidth: units.iconSizes.large
            source: messageWidget.icon
        }

        Label {
            id: label
            anchors.verticalCenter: parent.verticalCenter
            Layout.fillWidth: true
            verticalAlignment: Text.AlignVCenter
            wrapMode: Text.WordWrap
            color: messageWidget.labelColor
        }

        PlasmaComponents.ToolButton {
            id: closeButton
            anchors.verticalCenter: parent.verticalCenter
            iconName: "dialog-close"
            flat: true

            onClicked: {
                messageWidget.visible = false
            }
        }
    }
}
