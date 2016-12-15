import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Window 2.2

import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import QtQuick.Controls.Styles.Plasma 2.0 as PlasmaStyles

import org.kde.plasma.private.notes 0.1

MouseArea {
    id: mouseArea
    hoverEnabled: true
    // width: 800
    // height: Math.min(Math.max(400, listView.implicitHeight, 400), Screen.desktopAvailableHeight)
    Layout.minimumWidth: units.gridUnit * 10
    Layout.minimumHeight: units.gridUnit * 10
    Layout.preferredWidth: units.gridUnit * 20
    Layout.preferredHeight: Math.min(Math.max(units.gridUnit * 20, listView.contentHeight), Screen.desktopAvailableHeight) // Binding loop warning (meh).
    // Layout.maximumWidth: plasmoid.screenGeometry.width
    // Layout.maximumHeight: plasmoid.screenGeometry.height

    property bool isDesktopContainment: false

    // Rectangle {
    //  anchors.fill: parent
    //  color: "#000"
    //  opacity: mouseArea.containsMouse ? 0.25 : 0
    //  Behavior on opacity {
    //      NumberAnimation { duration: 400 }
    //  }
    // }

    Component.onCompleted: {
        // console.log('Floating', PlasmaCore.Types.Floating)
        // console.log('Desktop', PlasmaCore.Types.Desktop)
        // console.log('containmentType', plasmoid.containmentType)
        // console.log('location', plasmoid.location)
        if (typeof parent === 'undefined') {
            width = Layout.preferredWidth
            height = Layout.preferredHeight
        }
    }
    Component.onDestruction: {
        noteItem.saveNote()
    }

    RowLayout {
        id: container
        anchors.fill: parent
        // anchors.rightMargin: units.smallSpacing + rightMenu.width

        ListView {
            id: listView
            Layout.fillWidth: true
            Layout.fillHeight: true
            // anchors.fill: parent

            model: noteItem.filterModel
            cacheBuffer: 10000000
            spacing: 4

            delegate: TodoItemDelegate {}
            
            remove: Transition {
                NumberAnimation { property: "opacity"; to: 0; duration: 400 }
            }
            add: Transition {
                NumberAnimation { property: "opacity"; from: 0; to: 1.0; duration: 400 }
            }
            displaced: Transition {
                NumberAnimation { properties: "x,y"; duration: 200; }
            }

            Timer {
                id: deboucedPositionViewAtEnd
                interval: 1000
                onTriggered: listView.positionViewAtEnd()
            }

            Connections {
                target: noteItem.filterModel
                onCountChanged: {
                    // console.log('onCountChanged', count)
                    deboucedPositionViewAtEnd.restart()
                }
            }

            onCurrentItemChanged: {
                // console.log('listView.onCurrentItemChanged', currentIndex)
            }
        }

        Column {
            id: rightMenu
            property int iconSize: units.iconSizes.medium
            width: iconSize
            anchors.top: parent.top
            visible: !isDesktopContainment
            // anchors.right: parent.right
            // anchors.bottom: parent.bottom
            spacing: units.smallSpacing

            PlasmaComponents.ToolButton {
                anchors.right: parent.right
                width: Math.round(units.gridUnit * 1.25)
                height: width
                checkable: true
                iconSource: "window-pin"
                onCheckedChanged: plasmoid.hideOnWindowDeactivate = !checked
                visible: !isDesktopContainment
            }

            Item { height: units.smallSpacing; width: 1; visible: !isDesktopContainment }

            PlasmaComponents.ToolButton {
                width: rightMenu.iconSize
                height: width
                checked: plasmoid.configuration.showCompletedItems
                checkable: true
                iconSource: 'checkmark'
                onClicked: {
                    plasmoid.configuration.showCompletedItems = !plasmoid.configuration.showCompletedItems
                }
            }

        }
        
    }

    
}
