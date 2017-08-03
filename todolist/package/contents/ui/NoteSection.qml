import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1
import QtQuick.Window 2.2

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras
import QtQuick.Controls.Styles.Plasma 2.0 as PlasmaStyles

import org.kde.draganddrop 2.0 as DragAndDrop
import org.kde.plasma.private.notes 0.1

ColumnLayout {
    id: container
    Layout.fillWidth: true
    Layout.fillHeight: true
    spacing: 0
    
    property var noteSection: noteItem.sectionList[index]

    MouseArea {
        id: labelMouseArea
        Layout.fillWidth: true
        Layout.preferredHeight: labelRow.height
        hoverEnabled: true
        cursorShape: Qt.OpenHandCursor

        DropArea {
            id: noteSectionDropArea
            anchors.fill: parent
            z: -1
            // anchors.margins: 10

            onDropped: {
                // console.log('noteSectionDropArea.onDropped', drag.source.dragSectionIndex, index)
                if (typeof drag.source.dragSectionIndex === "number") {
                    // swap drag.source.dragNoteIndex and labelRow.dragNoteIndex
                    noteItem.moveSection(drag.source.dragSectionIndex, labelRow.dragSectionIndex)
                }
            }

            Rectangle {
                anchors.fill: parent
                color: parent.containsDrag ? "#88336699" : "transparent"
            }
        }

        RowLayout {
            id: labelRow
            anchors.left: parent.left
            anchors.right: parent.right
            
            property int dragSectionIndex: index

            DragAndDrop.DragArea {
                id: dragArea
                Layout.fillHeight: true
                Layout.preferredWidth: 30 * units.devicePixelRatio // Same width as drag area in todoItem

                delegate: labelRow

                PlasmaCore.FrameSvgItem {
                    visible: labelMouseArea.containsMouse && !noteSectionDropArea.containsDrag
                    anchors.horizontalCenter: parent.horizontalCenter
                    anchors.top: parent.top
                    anchors.bottom: parent.bottom
                    width: parent.width / 2
                    imagePath: plasmoid.file("", "images/dragarea.svg")
                }
            }

            TextField {
                id: textField
                Layout.fillWidth: true
                text: noteSection.label

                style: TextFieldStyle {
                    id: style
                    font.pointSize: -1
                    font.pixelSize: pinButton.height
                    background: Item {}
                    textColor: theme.textColor
                    placeholderTextColor: "#777"

                    padding.top: 0
                    padding.bottom: 0
                    padding.left: 0
                    padding.right: 0

                }
            }
        }
    }

    PlasmaExtras.ScrollArea {
        Layout.fillWidth: true
        Layout.fillHeight: true

        NoteListView {
            id: noteListView
            model: noteSection.model
        }
    }
}
