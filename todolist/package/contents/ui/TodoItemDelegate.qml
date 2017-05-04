import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1

import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import QtQuick.Controls.Styles.Plasma 2.0 as PlasmaStyles

Item {
    id: todoItemDelegate
    width: parent.width
    height: Math.max(checkbox.height, textArea.height)

    function setComplete(completed) {
        var newStatus = completed ? 'completed' : 'needsAction'
        if (model.status != newStatus) {
            // model.status = newStatus // Not supported in KDE 5.5
            filterModel.setProperty(index, 'status', newStatus)
            // console.log(completed, model.status)
            filterModel.update()
        }
    }
    function setTitle(title) {
        if (model.title != title) {
            // console.log('setTitle')
            // model.title = title // Not supported in KDE 5.5
            filterModel.setProperty(index, 'title', title)
            filterModel.update()
        }
    }
    function setIndent(indent) {
        if (model.indent != indent) {
            // model.indent = Math.max(0, indent) // Not supported in KDE 5.5
            filterModel.setProperty(index, 'indent', Math.max(0, indent))
            // indentItem.width = checkbox.height * indent
            // console.log(indent, model.indent, indentItem.width)
            // console.log(model.title)
            filterModel.update()
        }
    }
    function deleteItem() {
        filterModel.removeItem(index)
    }


DropArea {
    anchors.fill: parent
    // z: 1
    // anchors.margins: 10

    onEntered: {
        // visualModel.items.move(
        //         drag.source.DelegateModel.itemsIndex,
        //         dragArea.DelegateModel.itemsIndex)
        console.log('onEntered.index', index)
        console.log('onEntered.drag.source', drag.source)
        // console.log('onEntered.drag.source.ListView', drag.source.ListView)
        // console.log('onEntered.drag.source.DelegateModel.index', drag.source.index)

        filterModel.moveItem(drag.source.dragItemIndex, index)

    }

    Rectangle {
        anchors.fill: parent
        color: parent.containsDrag ? "#88336699" : "transparent"
    }
}

RowLayout {
    id: todoItemRow
    // anchors.left: parent.left
    // anchors.right: parent.right
    // height:
    // anchors.fill: parent
    width: parent.width
    height: parent.height
    // height: 48
    // Layout.fillWidth: true
    spacing: 0

    Item {
        id: indentItem
        Layout.preferredWidth: checkbox.height * model.indent
        visible: model.indent > 0
    }

    Drag.active: dragArea.pressed
    Drag.source: dragArea
    Drag.hotSpot.x: dragArea.width / 2
    Drag.hotSpot.y: dragArea.height / 2

    MouseArea {
        id: dragArea
        Layout.fillHeight: true
        Layout.preferredWidth: checkbox.height
        property int dragItemIndex: index

        // property bool held: false
        // drag.target: held ? todoItemRow : undefined
        drag.target: todoItemRow
        // drag.axis: Drag.YAxis

        // onPressAndHold: held = true
        // onReleased: held = false

        Rectangle {
            id: dragAreaRect
            color: "#88FFFFFF"
            anchors.horizontalCenter: parent.horizontalCenter
            anchors.top: parent.top
            anchors.bottom: parent.bottom
            width: parent.width / 2
        }
    }

    PlasmaComponents.CheckBox {
        id: checkbox
        anchors.top: parent.top
        Layout.preferredHeight: 30 * units.devicePixelRatio
        Layout.preferredWidth: 30 * units.devicePixelRatio
        checked: model.status == 'completed'
        enabled: model.title

        onClicked: setComplete(checked)

        style: PlasmaStyles.CheckBoxStyle {
            label: Item {} // Don't scale icon to font height
        }
    }
    Item {
        Layout.fillWidth: true
        anchors.top: parent.top

        TextArea {
            id: textArea
            width: parent.width
            // Layout.fillHeight: true
            
            // height: {
            //  console.log(leftPadding)
            //  return Math.max(leftPadding * 2 + font.pixelSize, implicitHeight)
            // }
            // autoSize: true

            tabChangesFocus: false
            focus: todoItemDelegate.ListView.isCurrentItem
            onActiveFocusChanged: {
                if (activeFocus) {
                    listView.currentIndex = index
                }
            }

            Timer {
                id: delayedSelect
                property int cursorPosition: -1
                interval: 100

                onTriggered: {
                    textArea.forceActiveFocus()
                    textArea.cursorPosition = delayedSelect.cursorPosition
                }
            }

            onLinkActivated: {
                Qt.openUrlExternally(link)
            }

            property bool isEditing: activeFocus
            // textFormat: TextEdit.PlainText
            // text: ''
            onTextChanged: {
                // console.log('onTextChanged')
                if (isEditing && textFormat == TextEdit.PlainText) {
                    setTitle(text)
                    // console.log(model.title)
                }
                // height = frameLinesHeight(lineCount)
                // parent.height = height
                // parent.parent.height = height
            }
            onIsEditingChanged: updateText()
            Component.onCompleted: updateText()

            function updateText() {
                // console.log('updateText')
                if (isEditing) {
                    var cursor = cursorPosition;
                    textFormat = TextEdit.PlainText
                    text = model.title
                    cursorPosition = cursor
                } else {
                    text = renderText(model.title)
                    textFormat = TextEdit.RichText
                }
            }

            // backgroundVisible: activeFocus
            textMargin: 0
            property int frameWidth: 6
            height: frameLinesHeight(lineCount)

            function frameLinesHeight(lines) {
                return contentHeight + 2*textMargin + 2*frameWidth
            }

            function renderText(text) {
                // console.log('renderText')
                if (typeof text === 'undefined') {
                    return '';
                }
                var out = text;

                // Escape HTML
                out = out.replace(/[\u00A0-\u9999<>\&]/gim, function(i) {
                    return '&#' + i.charCodeAt(0) + ';';
                });
                
                // Render links
                var rUrl = /(http|https):\/\/[\w-]+(\.[\w-]+)+([\w.,@?^=%&amp;:\/~+#-]*[\w@?^=%&amp;\/~+#-])?/gi;
                out = out.replace(rUrl, function(m) {
                    return '<a href="' + m + '">' + m + '</a>' + ' '; // Extra space to prevent styling entire text as a link when ending with a link.
                });

                // Render new lines
                out = out.replace(/\n/g, '<br>');

                return out;
            }

            style: PlasmaStyles.TextAreaStyle {}

            Keys.onPressed: {
                if (event.key == Qt.Key_Tab) {
                    setIndent(model.indent + 1);
                    event.accepted = true
                } else if (event.key == Qt.Key_Backtab) {
                    setIndent(model.indent - 1);
                    event.accepted = true
                } else if (event.key == Qt.Key_Return && event.modifiers == Qt.NoModifier) {
                    // console.log('returnPressed')
                    event.accepted = true
                    // nextItemInFocusChain().nextItemInFocusChain().focus = true
                    listView.currentIndex = index + 1
                } else if (event.key == Qt.Key_Up && event.modifiers == Qt.ControlModifier) {
                    event.accepted = true
                    if (index > 0) {
                        delayedSelect.cursorPosition = cursorPosition
                        filterModel.moveItem(index, index-1)
                        // todoModel.move(index, index-1, 1)
                        delayedSelect.restart()
                    }
                } else if (event.key == Qt.Key_Down && event.modifiers == Qt.ControlModifier) {
                    event.accepted = true
                    if (index < filterModel.count-1) {
                    // if (index < todoModel.count-1) {
                        delayedSelect.cursorPosition = cursorPosition
                        filterModel.moveItem(index, index+1)
                        // todoModel.move(index, index+1, 1)
                        delayedSelect.restart()
                    }
                }
            }
        }
    }

    // PlasmaComponents.ToolButton {
    //     id: removeButton
    //     anchors.top: parent.top
    //     height: 30
    //     iconName: 'list-remove-symbolic'
    //     opacity: textArea.activeFocus || hovered ? 1 : 0

    //     onClicked: {
    //         filterModel.removeItem(index)
    //     }
    // }
}

}
