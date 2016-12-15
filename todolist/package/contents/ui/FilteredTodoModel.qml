import QtQuick 2.0

import org.kde.plasma.core 2.0 as PlasmaCore

PlasmaCore.SortFilterModel {
    id: filterModel
    sourceModel: todoModel
    filterRole: "isVisible"
    filterRegExp: ""

    function removeItem(index) {
        sourceModel.removeItem(mapRowToSource(index))
    }

    function setProperty(index, key, value) {
        sourceModel.setProperty(mapRowToSource(index), key, value)
    }

    function update() {
        sourceModel.update()
    }

    function addTemplateIfNeeded() {
        // console.log('addTemplateIfNeeded')
        if (filterModel.count == 0 || !isEmptyItem(filterModel.get(filterModel.count-1))) {
            var lastItem = filterModel.get(filterModel.count-1);
            // console.log('addTemplateIfNeeded', lastItem, lastItem.title)
            // for (var key in lastItem) {
            //     console.log(key, lastItem[key]);
            // }
            sourceModel.append(newTodoItem());
            // console.log('addTemplateIfNeeded', 'added')
        } else {

            // console.log('addTemplateIfNeeded', 'no')
        }
    }

    function updateVisibleItems() {
        var hasUpdated = false;
        var incompleteCount = 0;
        for (var i = 0; i < sourceModel.count; i++) {
            var todoItem = sourceModel.get(i);
            var wasVisible = todoItem.isVisible
            var incomplete = todoItem.status == 'needsAction'
            var shouldBeVisible = plasmoid.configuration.showCompletedItems || incomplete
            var isPlaceholder = !todoItem.title
            if (incomplete && !isPlaceholder) {
                incompleteCount += 1
            }
            // if (wasVisible != shouldBeVisible) {
                sourceModel.setProperty(i, 'isVisible', shouldBeVisible)
                // hasUpdated = true;
            // }
        }
        todoModel.incompleteCount = incompleteCount
        addTemplateIfNeeded()
    }
}
