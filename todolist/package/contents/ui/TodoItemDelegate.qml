import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1

import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import QtQuick.Controls.Styles.Plasma 2.0 as PlasmaStyles


RowLayout {
    id: todoItemRow
    // height: 48
    // Layout.fillWidth: true
    width: parent.width
    height: Math.max(checkbox.height, textArea.height)
    spacing: 0

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


    Item {
        id: indentItem
        Layout.preferredWidth: checkbox.height * model.indent
        visible: model.indent > 0
    }

    PlasmaComponents.CheckBox {
        id: checkbox
        anchors.top: parent.top
        // Layout.fillHeight: true
        height: 30
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
            focus: todoItemRow.ListView.isCurrentItem
            onActiveFocusChanged: {
                if (activeFocus) {
                    listView.currentIndex = index
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
                }
            }
        }
    }

    PlasmaComponents.ToolButton {
        id: removeButton
        anchors.top: parent.top
        height: 30
        iconName: 'list-remove-symbolic'
        opacity: textArea.activeFocus || hovered ? 1 : 0
        
        onClicked: {
            filterModel.removeItem(index)
        }
    }
}
