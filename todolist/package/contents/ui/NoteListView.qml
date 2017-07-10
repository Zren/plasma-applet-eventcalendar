import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1

import org.kde.plasma.core 2.0 as PlasmaCore

ListView {
    id: listView
    Layout.fillWidth: true
    Layout.fillHeight: true

    cacheBuffer: 10000000
    // interactive: false
    spacing: 4
    verticalLayoutDirection: plasmoid.location == PlasmaCore.Types.TopEdge ? ListView.BottomToTop : ListView.TopToBottom

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

    onCountChanged: {
        // console.log('onCountChanged', count)
        deboucedPositionViewAtEnd.restart()
    }

    onCurrentItemChanged: {
        // console.log('listView.onCurrentItemChanged', currentIndex)
    }

    Connections {
        target: plasmoid
        onExpandedChanged: {
            if (expanded) {
                listView.focus = true
                listView.currentIndex = listView.count - 1
                listView.positionViewAtEnd()
            }
        }
    }
}
