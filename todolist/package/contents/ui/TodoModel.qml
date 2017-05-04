import QtQuick 2.0

import org.kde.plasma.core 2.0 as PlasmaCore

ListModel {
    id: todoModel
    signal update()
    
    property int incompleteCount: 0

    function removeItem(index) {
        // console.log('removeItem', index)
        remove(index, 1)
        // addTemplateIfNeeded()
        update()
    }

    function setData(todoData) {
        // console.log('setData')
        clear()
        for (var i = 0; i < todoData.length; i++) {
            append(todoData[i]);
            // console.log('setData', 'append', todoData[i])
        }
        // addTemplateIfNeeded()
        update()
    }

    function addTemplateIfNeeded() {
        // console.log('addTemplateIfNeeded')
        if (count == 0 || !noteItem.isEmptyItem(get(count-1))) {
            var lastItem = get(count-1);
            append(newTodoItem());
            console.log('addTemplateIfNeeded', 'added')
        } else {
            console.log('addTemplateIfNeeded', 'no')
        }
    }

    function updateVisibleItems() {
        var hasUpdated = false;
        var incompleteCount = 0;
        for (var i = 0; i < count; i++) {
            var todoItem = get(i);
            var wasVisible = todoItem.isVisible
            var incomplete = todoItem.status == 'needsAction'
            var shouldBeVisible = plasmoid.configuration.showCompletedItems || incomplete
            var isPlaceholder = !todoItem.title
            if (incomplete && !isPlaceholder) {
                incompleteCount += 1
            }
            // if (wasVisible != shouldBeVisible) {
                setProperty(i, 'isVisible', shouldBeVisible)
                // hasUpdated = true;
            // }
        }
        todoModel.incompleteCount = incompleteCount
        addTemplateIfNeeded()
    }
}
