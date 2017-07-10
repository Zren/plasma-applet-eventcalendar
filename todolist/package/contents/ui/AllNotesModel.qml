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
    id: allNotesModel

    property var noteItemList: { return {} }

    property int numLists: 3
    property var noteIdList: {
        var l = []
        for (var i = 0; i < numLists; i++) {
            var noteId = 'todolist'
            if (i > 0) { // todolist, todolist2, todolist3, ...
                noteId += (i+1)
            }
            l.push(noteId)
        }
        return l
    }

    Repeater {
        model: noteIdList
        NoteItem {
            id: noteItem
            noteId: modelData

            Component.onCompleted: {
                noteItemList[modelData] = noteItem
                todoModel.incompleteCountChanged.connect(allNotesModel.updateIncompleteCount)
                allNotesModel.updateIncompleteCount()
            }
            Component.onDestruction: {
                noteItem.saveNote()
            }
        }
    }

    property int incompleteCount: 0
    function updateIncompleteCount() {
        var n = 0
        for (var i = 0; i < noteIdList.length; i++) {
            var noteId = noteIdList[i]
            var noteItem = noteItemList[noteId]
            if (noteItem) {
                n += noteItem.todoModel.incompleteCount
            }
        }
        incompleteCount = n
    }
}
