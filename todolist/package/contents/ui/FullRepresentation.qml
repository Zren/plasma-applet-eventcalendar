import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Window 2.2

import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras
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

    ColumnLayout {
        id: container
        anchors.fill: parent

        PlasmaComponents.ToolButton {
            anchors.right: parent.right
            Layout.preferredWidth: Math.round(units.gridUnit * 1.25)
            Layout.preferredHeight: width
            checkable: true
            iconSource: "window-pin"
            onCheckedChanged: plasmoid.hideOnWindowDeactivate = !checked
            visible: !isDesktopContainment
        }

        PlasmaExtras.ScrollArea {
            Layout.fillWidth: true
            Layout.fillHeight: true

            ListView {
                id: listView
                Layout.fillWidth: true
                Layout.fillHeight: true

                model: noteItem.todoModel
                cacheBuffer: 10000000
                // interactive: false
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

                onCountChanged: {
                    // console.log('onCountChanged', count)
                    deboucedPositionViewAtEnd.restart()
                }

                onCurrentItemChanged: {
                    // console.log('listView.onCurrentItemChanged', currentIndex)
                }

                Connections {
                    target: plasmoid
                    onExpandedChanged: {
                        if (expanded) {
                            listView.focus = true
                            listView.currentIndex = listView.count - 1
                            listView.positionViewAtEnd()
                        }
                    }
                }
            }
        }
    }

    
}
