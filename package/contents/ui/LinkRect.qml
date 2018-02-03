import QtQuick 2.0
import QtQuick.Layouts 1.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

import "lib"

Rectangle {
    id: linkRect
    width: implicitWidth
    height: implicitHeight
    implicitWidth: childrenRect.width
    implicitHeight: childrenRect.height
    property color backgroundColor: "transparent"
    property color backgroundHoverColor: theme.buttonBackgroundColor
    color: enabled && mouseArea.containsMouse ? backgroundHoverColor : backgroundColor
    property string tooltipMainText
    property string tooltipSubText
    property alias acceptedButtons: mouseArea.acceptedButtons
    property bool enabled: true

    signal clicked(var mouse)
    signal leftClicked(var mouse)
    signal doubleClicked(var mouse)
    signal loadContextMenu(var contextMenu)
    
    PlasmaCore.ToolTipArea {
        id: tooltip
        anchors.fill: parent
        mainText: linkRect.tooltipMainText
        subText: linkRect.tooltipSubText

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            acceptedButtons: Qt.LeftButton | Qt.RightButton
            cursorShape: linkRect.enabled && containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
            enabled: linkRect.enabled
            onClicked: {
                mouse.accepted = false
                linkRect.clicked(mouse)
                if (!mouse.accepted) {
                    if (mouse.button == Qt.LeftButton) {
                        linkRect.leftClicked(mouse)
                    } else if (mouse.button == Qt.RightButton) {
                        contextMenu.show(mouse.x, mouse.y)
                        mouse.accepted = true
                    }
                }
            }
            onDoubleClicked: linkRect.doubleClicked(mouse)
        }
    }

    ContextMenu {
        id: contextMenu
        onPopulate: linkRect.loadContextMenu(contextMenu)
    }
}
