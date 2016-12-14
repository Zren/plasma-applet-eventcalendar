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
}
