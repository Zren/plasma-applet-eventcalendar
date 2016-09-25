import QtQuick 2.0
import QtQuick.Layouts 1.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

Rectangle {
    id: linkRect
    width: childrenRect.width
    height: childrenRect.height
    property color backgroundColor: "transparent"
    property color backgroundHoverColor: theme.buttonBackgroundColor
    color: mouseArea.containsMouse ? backgroundHoverColor : backgroundColor
    property string tooltipMainText
    property string tooltipSubText
    property alias acceptedButtons: mouseArea.acceptedButtons

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
            cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
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

    PlasmaComponents.ContextMenu {
        id: contextMenu

        function newSeperator() {
            return Qt.createQmlObject("import org.kde.plasma.components 2.0 as PlasmaComponents; PlasmaComponents.MenuItem { separator: true }", contextMenu);
        }
        function newMenuItem() {
            return Qt.createQmlObject("import org.kde.plasma.components 2.0 as PlasmaComponents; PlasmaComponents.MenuItem {}", contextMenu);
        }

        function loadMenu() {
            contextMenu.clearMenuItems();
            linkRect.loadContextMenu(contextMenu)
        }

        function show(x, y) {
            loadMenu();
            if (content.length > 0) {
                open(x, y);
            }
        }
    }
}
