import QtQuick 2.0
import QtQuick.Layouts 1.1
import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

Item {
    id: main

    // Plasmoid.icon: 'view-list-symbolic'

    NoteItem { id: noteItem }
    property alias todoModel: noteItem.todoModel
    property alias filterModel: noteItem.filterModel

    Plasmoid.compactRepresentation: MouseArea {
        PlasmaCore.IconItem {
            id: icon
            anchors.fill: parent
            source: 'view-list-symbolic'
        }
            
        IconCounterOverlay {
            anchors.fill: parent
            text: noteItem.todoModel.incompleteCount
            visible: noteItem.todoModel.incompleteCount > 0
            heightRatio: 0.5
        }

        onClicked: plasmoid.expanded = !plasmoid.expanded
    }

    Plasmoid.fullRepresentation: FullRepresentation {
        Plasmoid.backgroundHints: isDesktopContainment ? PlasmaCore.Types.NoBackground : PlasmaCore.Types.DefaultBackground
        isDesktopContainment: plasmoid.location == PlasmaCore.Types.Floating

        // Connections {
        //     target: plasmoid
        //     onExpandedChanged: {
        //         if (!expanded) {
        //             updateVisibleItems()
        //         }
        //     }
        // }
    }


    PlasmaCore.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []
        onNewData: disconnectSource(sourceName)
    }
    function exec(cmd) {
        executable.connectSource(cmd)
    }

    function action_openInTextEditor() {
        exec("xdg-open ~/.local/share/plasma_notes/todolist");
    }

    function action_toggleShowChecked() {
        plasmoid.configuration.showCompletedItems = !plasmoid.configuration.showCompletedItems
    }

    function updateContextMenu() {
        if (plasmoid.configuration.showCompletedItems) {
            plasmoid.setAction("toggleShowChecked", i18n("Hide Completed"), "checkmark");
        } else {
            plasmoid.setAction("toggleShowChecked", i18n("Show Completed"), "");
        }
    }

    Connections {
        target: plasmoid.configuration
        onShowCompletedItemsChanged: updateContextMenu()
    }

    Component.onCompleted: {
        plasmoid.setAction("openInTextEditor", i18n("Open in Text Editor"), "accessories-text-editor");
        updateContextMenu() // plasmoid.setAction("toggleShowChecked", ...)
        console.log('main.isDesktopContainment', plasmoid.location == PlasmaCore.Types.Desktop)
    }
}
