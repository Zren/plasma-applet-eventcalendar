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
    property int listViewHeight: listView.model.count * 30 +  (listView.model.count-1) * listView.spacing
    Layout.preferredHeight: Math.min(Math.max(units.gridUnit * 20, listViewHeight), Screen.desktopAvailableHeight)
    // Layout.maximumWidth: plasmoid.screenGeometry.width
    // Layout.maximumHeight: plasmoid.screenGeometry.height

    property bool isDesktopContainment: false
    
    property string noteId: 'todolist'
    NoteManager { id: noteManager }
    property QtObject note: noteManager.loadNote(noteId);
    property bool deserializeOnFileChange: true
    property bool saveOnChange: true
    property string noteText: ''
    Connections {
        target: note
        onNoteTextChanged: {
            console.log('note.onNoteTextChanged', note.noteText.length)
            // if (note.noteText != noteText) {
                noteText = note.noteText
                console.log('deserializeOnFileChange', deserializeOnFileChange, note.noteText.length)
                if (deserializeOnFileChange) {
                    loadNote()
                }
            // }
            // deserializeOnFileChange = true
            // console.log('deserializeOnFileChange = true')
            
            // console.log('noteText', note.noteText)
        }
    }
    function saveNote(str) {
        console.log('saveNote')
        if (!str) {
            str = serializeTodoModel();
        }

        deserializeOnFileChange = false
        note.save(str)
        deserializeOnFileChange = true
    }
    function loadNote() {
        console.log('loadNote')
        saveOnChange = false
        var todoData = deserializeTodoModel(note.noteText);
        todoModel.setData(todoData)
        saveOnChange = true
    }
    Timer {
        id: deboucedSaveNoteTimer
        interval: 1000
        onTriggered: saveNote()
    }
    function deboucedSaveNote() {
        console.log('deboucedSaveNote')
        deboucedSaveNoteTimer.restart()
    }

    Rectangle {
        visible: typeof main === 'undefined'
        anchors.fill: parent
        color: theme.backgroundColor
    }

    // Rectangle {
    //  anchors.fill: parent
    //  color: "#000"
    //  opacity: mouseArea.containsMouse ? 0.25 : 0
    //  Behavior on opacity {
    //      NumberAnimation { duration: 400 }
    //  }
    // }

    ListModel {
        id: todoModel
        signal update()

        function addTemplateIfNeeded() {
            // console.log('addTemplateIfNeeded')
            if (filterModel.count == 0 || !isEmptyItem(filterModel.get(filterModel.count-1))) {
                append(newTodoItem());
                console.log('addTemplateIfNeeded', 'added')
            } else {

                console.log('addTemplateIfNeeded', 'no')
            }
        }

        function removeItem(index) {
            console.log('removeItem', index)
            remove(index, 1)
            addTemplateIfNeeded()
            update()
        }

        function setData(todoData) {
            console.log('setData')
            clear()
            for (var i = 0; i < todoData.length; i++) {
                append(todoData[i]);
            }
            addTemplateIfNeeded()
            update()
        }

        function updateVisibleItems() {
            var hasUpdated = false;
            for (var i = 0; i < todoModel.count; i++) {
                var todoItem = todoModel.get(i);
                var wasVisible = todoModel.isVisible
                var shouldBeVisible = plasmoid.configuration.showCompletedItems || todoItem.status == 'needsAction';

                // if (wasVisible != shouldBeVisible) {
                    todoModel.setProperty(i, 'isVisible', shouldBeVisible)
                    // hasUpdated = true;
                // }
            }
            addTemplateIfNeeded()
        }

        onUpdate: {
            console.log('update')
            updateVisibleItems()
            deboucedSaveNote()
        }
    }

    property bool showCompletedItems: plasmoid.configuration.showCompletedItems
    onShowCompletedItemsChanged: todoModel.updateVisibleItems()
    PlasmaCore.SortFilterModel {
        id: filterModel
        sourceModel: todoModel
        filterRole: "isVisible"
        filterRegExp: ""

        function removeItem(index) {
            sourceModel.removeItem(mapRowToSource(index))
        }
    }
    // Timer {
    //  id: updateVisibleItemsTimer
    //  interval: 2000
    //  onTriggered: {
    //      todoModel.update()
    //  }
    // }


    Component.onCompleted: {
        // console.log('noteText.onload', note.noteText)
        console.log('Floating', PlasmaCore.Types.Floating)
        console.log('Desktop', PlasmaCore.Types.Desktop)
        console.log('containmentType', plasmoid.containmentType)
        console.log('location', plasmoid.location)
        if (typeof parent === 'undefined') {
            width = Layout.preferredWidth
            height = Layout.preferredHeight
        }
        loadNote()
        filterModel.filterRegExp = "true"
    }
    Component.onDestruction: {
        saveNote()
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

            model: filterModel //todoModel
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
                target: filterModel
                onCountChanged: {
                    console.log('onCountChanged', filterModel.count)
                    deboucedPositionViewAtEnd.restart()
                }
            }

            onCurrentItemChanged: {
                console.log('listView.onCurrentItemChanged', currentIndex)
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
    

    function repeat(s, n) {
        var out = '';
        for (var i = 0; i < n; i++) {
            out += s;
        }
        return out;
    }

    function serializeTodoModel() {
        var out = '';
        for (var i = 0; i < todoModel.count; i++) {
            var todoItem = todoModel.get(i);
            if (i == todoModel.count-1 && isEmptyItem(todoItem)) {
                break;
            }
            // console.log(i, todoItem);
            var line = '';
            line += repeat('    ', todoItem.indent)
            line += '* '
            line += todoItem.status == 'completed' ? '[x]' : '[ ]';
            line += ' ';
            var indent = line.length;
            var todoItemlines = todoItem.title.split('\n');
            line += todoItemlines[0];
            for (var j = 1; j < todoItemlines.length; j++) {
                line += '\n' + repeat(' ', indent) + todoItemlines[j];
            }
            out += line + '\n';
        }
        return out;
    }

    function isEmptyItem(todoItem) {
        return todoItem.title == '';
    }

    function newTodoItem() {
        return {
            title: '',
            status: 'needsAction',
            notes: '',
            indent: 0,
            isVisible: true,
        };
    }

    function isNewItem(line) {
        if (line.indexOf('*') == -1) {
            return false;
        }
        for (var i = 0; i < line.indexOf('*'); i++) {
            if (line[i] != ' ') {
                return false;
            }
        }
        return true;
    }

    function deserializeTodoModel(s) {
        var out = [];
        if (s && s[s.length-1] == '\n') {
            s = s.substr(0, s.length-1); // trim ending \n
        }
        var lines = s.split('\n');
        var todoItem;
        var indent = 0;
        for (var j = 0; j < lines.length; j++) {
            var line = lines[j];
            var newItem = isNewItem(line);
            if (newItem) {
                if (todoItem) {
                    out.push(todoItem);
                }
                todoItem = newTodoItem();
                todoItem.indent = line.indexOf('*') / 4;
                var checkboxIndex = line.indexOf('[');
                todoItem.status = (line[checkboxIndex + 1] == 'x') ? 'completed' : 'needsAction'

                indent = checkboxIndex + 'x] '.length
                todoItem.title = line.substr(indent + 1);
            } else if (todoItem) {
                todoItem.title += '\n' + line.substr(indent + 1);
            }
        }
        if (todoItem) {
            out.push(todoItem);
        }
        return out;
    }

    
    
}
