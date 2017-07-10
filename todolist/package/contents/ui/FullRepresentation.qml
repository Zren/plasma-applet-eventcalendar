import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1
import QtQuick.Window 2.2

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
    Layout.preferredWidth: units.gridUnit * 20 * allNotesModel.numLists
    Layout.preferredHeight: Math.min(Math.max(units.gridUnit * 20, maxContentHeight), Screen.desktopAvailableHeight) // Binding loop warning (meh).
    property int maxContentHeight: 0
    function updateMaxContentHeight() {
        var maxHeight = 0
        for (var i = 0; i < notesRepeater.count; i++) {
            var item = notesRepeater.itemAt(i)
            maxHeight = Math.max(maxHeight, item.contentHeight)
        }
        maxContentHeight = maxHeight
    }
    // property int contentHeight: pinButton.height + container.spacing + listView.contentHeight
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
        id: notesRow
        anchors.fill: parent

        Repeater {
            id: notesRepeater
            model: allNotesModel.noteIdList

            ColumnLayout {
                id: container
                Layout.fillWidth: true
                Layout.fillHeight: true

                property int contentHeight: label.height + container.spacing + noteListView.contentHeight
                onContentHeightChanged: mouseArea.updateMaxContentHeight()

                property string noteId: modelData
                property var noteItem: allNotesModel.noteItemList[noteId]

                PlasmaComponents.Label {
                    id: label
                    text: noteId
                    font.pointSize: -1
                    font.pixelSize: pinButton.height
                    Layout.preferredHeight: pinButton.height
                }

                PlasmaExtras.ScrollArea {
                    Layout.fillWidth: true
                    Layout.fillHeight: true

                    NoteListView {
                        id: noteListView
                        model: noteItem.todoModel
                    }
                }
            }
        }

    }

    PlasmaComponents.ToolButton {
        id: pinButton
        anchors.top: parent.top
        anchors.right: parent.right
        width: Math.round(units.gridUnit * 1.25)
        height: width
        checkable: true
        iconSource: "window-pin"
        onCheckedChanged: plasmoid.hideOnWindowDeactivate = !checked
        visible: !isDesktopContainment
    }
}
