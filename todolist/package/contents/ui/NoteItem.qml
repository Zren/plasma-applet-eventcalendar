import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Window 2.2

import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import QtQuick.Controls.Styles.Plasma 2.0 as PlasmaStyles

import org.kde.plasma.private.notes 0.1

Item {
    id: noteItem

    property string noteId: 'todolist'
    NoteManager { id: noteManager }
    property QtObject note: noteManager.loadNote(noteId)
    property bool deserializeOnFileChange: true
    property bool saveOnChange: true
    property string noteText: ''
    Connections {
        target: note
        onNoteTextChanged: {
            // console.log('note.onNoteTextChanged', note.noteText.length)
            // if (note.noteText != noteText) {
                noteItem.noteText = note.noteText
                // console.log('deserializeOnFileChange', noteItem.deserializeOnFileChange, note.noteText.length)
                if (noteItem.deserializeOnFileChange) {
                    noteItem.loadNote()
                }
            // }
            // noteItem.deserializeOnFileChange = true
            // console.log('deserializeOnFileChange = true')
            
            // console.log('noteText', note.noteText)
        }
    }
    function saveNote(str) {
        // console.log('saveNote')
        if (!str) {
            str = serializeTodoModel();
        }

        deserializeOnFileChange = false
        note.save(str)
        deserializeOnFileChange = true
    }
    function loadNote() {
        // console.log('loadNote')
        saveOnChange = false
        var todoData = noteItem.deserializeTodoModel(note.noteText)
        todoModel.setData(todoData)
        saveOnChange = true
    }
    Timer {
        id: deboucedSaveNoteTimer
        interval: 1000
        onTriggered: saveNote()
    }
    function deboucedSaveNote() {
        // console.log('deboucedSaveNote')
        deboucedSaveNoteTimer.restart()
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
            if (!(line[i] === ' ' || line[i] === '\t')) {
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
                
                if (checkboxIndex >= 0) {
                    todoItem.status = (line[checkboxIndex + 1] == 'x') ? 'completed' : 'needsAction';
                    todoItem.title = line.substr(checkboxIndex + 'x] '.length + 1);
                } else { // Does not have [x]
                    todoItem.status = false;
                    todoItem.title = line.substr(line.indexOf('*') + ' '.length + 1);
                }
            } else if (todoItem) {
                var startIndex = 0;
                for (var i = 0; i < line.length; i++) {
                    if (line[i] === ' ' || line[i] === '\t') {
                        continue;
                    } else {
                        startIndex = i;
                        break;
                    }
                }
                todoItem.title += '\n' + line.substr(startIndex);
            }
        }
        if (todoItem) {
            out.push(todoItem);
        }
        // console.log(JSON.stringify(out, null, '\t'))
        return out;
    }


    // public
    property alias todoModel: todoModel
    property alias filterModel: filterModel

    TodoModel {
        id: todoModel
        onUpdate: {
            filterModel.updateVisibleItems()
            noteItem.deboucedSaveNote()
        }
    }

    FilteredTodoModel {
        id: filterModel
    }
    Connections {
        target: plasmoid.configuration
        onShowCompletedItemsChanged: filterModel.updateVisibleItems()
    }

    Component.onCompleted: {
        loadNote()
        filterModel.filterRegExp = "true"
    }
    Component.onDestruction: {
        saveNote()
    }
}
