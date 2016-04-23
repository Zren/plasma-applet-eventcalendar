import QtQuick 2.0
import QtQuick.Layouts 1.0
import org.kde.plasma.core 2.0 as PlasmaCore

Rectangle {
    id: linkRect
    width: childrenRect.width
    height: childrenRect.height
    property color backgroundColor: "transparent"
    property color backgroundHoverColor: theme.buttonBackgroundColor
    color: mouseArea.containsMouse ? backgroundHoverColor : backgroundColor
    property string tooltipMainText
    property string tooltipSubText

    signal clicked()
    
    PlasmaCore.ToolTipArea {
        id: tooltip
        anchors.fill: parent
        mainText: linkRect.tooltipMainText
        subText: linkRect.tooltipSubText

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: containsMouse ? Qt.PointingHandCursor : Qt.ArrowCursor
            onClicked: {
                linkRect.clicked()
            }
        }
    }
}