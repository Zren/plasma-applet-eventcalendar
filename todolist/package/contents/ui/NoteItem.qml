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
        // if (!allSectionsLoaded()) {
        //     return;
        // }

        if (!str) {
            str = serializeTodoModel();
        }

        deserializeOnFileChange = false
        note.save(str)
        deserializeOnFileChange = true
    }
    function loadNote() {
        // console.log('loadNote')
        var savingOnChange = saveOnChange
        saveOnChange = false
        todoData = noteItem.deserializeTodoModel(note.noteText)
        numSections = todoData.length
        updateAllModels()
        saveOnChange = savingOnChange
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
        // console.log('serializeTodoModel')

        for (var sectionIndex = 0; sectionIndex < numSections; sectionIndex++) {
            var noteSection = sectionList[sectionIndex];
            if (noteSection.label || sectionIndex > 0) { // Don't add heading if the first label is empty
                if (sectionIndex > 0) { // Don't add "top margin" for first heading
                    out += '\n'
                }
                out += '# ' + rtrim(noteSection.label) + '\n\n';
            }
            var todoModel = noteSection.model
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
                    // line += '\n'
                    // var trimmedLine = rtrim(todoItemlines[j]);
                    // if (trimmedLine.length > 0) {
                    //     line += repeat(' ', indent) + trimmedLine;
                    // }
                    line += '\n' + repeat(' ', indent) + todoItemlines[j];
                }
                out += line + '\n';
            }
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

    function isHeading(line) {
        return line.indexOf('#') == 0
    }

    function getStartIndex(line, startIndex) {
        for (var i = startIndex; i < line.length; i++) {
            if (line[i] === ' ' || line[i] === '\t') {
                continue;
            } else {
                startIndex = i;
                break;
            }
        }
        return startIndex;
    }
    
    function _addSectionTo(out) {
        out.push({
            label: '',
            items: [],
        });
    }

    function rtrim(s) { // trim spaces, tabs, and newlines
        if (s && s.length > 0) {
            for (var i = s.length-1; i >= 0; i--) {
                if (!(s[i] == ' ' || s[i] == '\t' || s[i] == '\n')) {
                    return s.substr(0, i+1);
                }
            }
            return '';
        } else {
            return s;
        }
    }
    function trimLastNewline(s) {
        if (s && s[s.length-1] == '\n') {
            return s.substr(0, s.length-1); // trim ending \n
        } else {
            return s;
        }
    }
    function deserializeTodoModel(s) {
        var sectionIndex = 0;
        var out = [];
        _addSectionTo(out);

        s = trimLastNewline(s);

        var lines = s.split('\n');
        var todoItem;
        for (var j = 0; j < lines.length; j++) {
            var line = lines[j];
            var newItem = isNewItem(line);
            if (newItem) {
                if (todoItem) {
                    // console.log('items.push(newItem)', out[sectionIndex].label, todoItem.title)
                    out[sectionIndex].items.push(todoItem);
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
            } else if (isHeading(line)) {
                if (todoItem) {
                    todoItem.title = trimLastNewline(todoItem.title);
                    if (todoItem.title) {
                        // console.log('items.push(newHeading)', out[sectionIndex].label, todoItem.title)
                        out[sectionIndex].items.push(todoItem);
                        todoItem = null;
                    }
                }
                var startIndex = getStartIndex(line, 1);
                if (!(sectionIndex == 0 && out[sectionIndex].items.length == 0)) { // Not the first heading
                    _addSectionTo(out);
                    sectionIndex += 1;
                }
                out[sectionIndex].label = rtrim(line.substr(startIndex));
            } else if (todoItem) {
                var startIndex = getStartIndex(line, 0);
                var lineContents = line.substr(startIndex);
                lineContents = rtrim(lineContents);
                if (todoItem) {
                    todoItem.title += '\n' + lineContents;
                } else {
                    // console.log('skipped line')
                }
            }
        }
        if (todoItem) {
            // console.log('items.push(last)', out[sectionIndex].label, todoItem.title)
            out[sectionIndex].items.push(todoItem);
        }
        // console.log('deserializeTodoModel', JSON.stringify(out, null, '\t'))
        return out;
    }

    // property string noteLabel: ''
    // onNoteLabelChanged: {
    //     noteItem.deboucedSaveNote()
    // }

    // public
    // property alias todoModel: todoModel

    // TodoModel {
    //     id: todoModel
    //     onUpdate: {
    //         todoModel.updateVisibleItems()
    //         noteItem.deboucedSaveNote()
    //     }
    // }

    property int incompleteCount: 0
    function updateIncompleteCount() {
        var n = 0
        for (var i = 0; i < numSections; i++) {
            var noteSection = sectionList[i]
            if (noteSection) {
                n += noteSection.model.incompleteCount
            }
        }
        incompleteCount = n
    }

    property variant todoData: []
    function updateAllModels() {
        for (var i = 0; i < numSections; i++) {
            updateSectionModel(i)
        }
    }
    function updateSectionModel(sectionIndex) {
        sectionList[sectionIndex].setData(todoData[sectionIndex])
    }

    function updateTodoData() {
        todoData = deserializeTodoModel(serializeTodoModel())
    }

    function moveSection(sectionIndex, insertIndex) {
        updateTodoData() // First make sure todoData is updated
        var arr = todoData.splice(sectionIndex, 1)
        todoData.splice(insertIndex, 0, arr[0])
        updateAllModels()
    }

    function addSection() {
        updateTodoData() // First make sure todoData is updated
        _addSectionTo(todoData)
        numSections += 1
    }

    function removeSection(sectionIndex) {
        updateTodoData() // First make sure todoData is updated
        todoData.splice(sectionIndex, 1)
        numSections -= 1
        updateAllModels()
    }

    property var sectionList: { return {} }
    property int numSections: 1

    Repeater {
        model: noteItem.numSections
        Item {
            id: noteSectionItem
            property string label: ''
            onLabelChanged: noteItem.deboucedSaveNote()

            function setData(sectionData) {
                label = sectionData.label
                model.setData(sectionData.items)
            }

            property alias model: model
            TodoModel {
                id: model
                onUpdate: {
                    model.updateVisibleItems()
                    noteItem.deboucedSaveNote()
                }
            }

            Component.onCompleted: {
                noteItem.sectionList[index] = noteSectionItem
                noteItem.updateSectionModel(index)
                noteSectionItem.model.incompleteCountChanged.connect(noteItem.updateIncompleteCount)
                noteItem.updateIncompleteCount()
            }
            Component.onDestruction: {
                // noteItem.saveNote()
                delete noteItem.sectionList[index]
            }
        }
    }

    Connections {
        target: plasmoid.configuration
        onShowCompletedItemsChanged: todoModel.updateVisibleItems()
    }

    Component.onCompleted: {
        loadNote()
    }
    Component.onDestruction: {
        saveNote()
    }
}
