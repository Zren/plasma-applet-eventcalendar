// Based off kicker's ActionMenu
import QtQuick 2.0
import org.kde.plasma.components 2.0 as PlasmaComponents

Item {
    id: root

    property QtObject menu
    property Item visualParent
    property bool opened: menu ? (menu.status != PlasmaComponents.DialogStatus.Closed) : false

    signal closed
    signal populateMenu(var menu)

    onOpenedChanged: {
        if (!opened) {
            closed();
        }
    }

    function open(x, y) {
        refreshMenu()

        if (menu.content.length === 0) {
            return;
        }

        if (x && y) {
            menu.open(x, y);
        } else {
            menu.open();
        }
    }

    function refreshMenu() {
        if (menu) {
            menu.destroy();
        }

        menu = contextMenuComponent.createObject(root);
        populateMenu(menu)
    }

    Component {
        id: contextMenuComponent

        PlasmaComponents.ContextMenu {
            id: contextMenu
            visualParent: root.visualParent

            function newSeperator() {
                return Qt.createQmlObject("import org.kde.plasma.components 2.0 as PlasmaComponents; PlasmaComponents.MenuItem { separator: true }", contextMenu);
            }
            function newMenuItem() {
                return Qt.createQmlObject("import org.kde.plasma.components 2.0 as PlasmaComponents; PlasmaComponents.MenuItem {}", contextMenu);
            }

            
        }
    }

    Component {
        id: contextMenuItemComponent

        PlasmaComponents.MenuItem {
            property variant actionItem

            text: actionItem.text ? actionItem.text : ""
            enabled: actionItem.type != "title" && ("enabled" in actionItem ? actionItem.enabled : true)
            separator: actionItem.type == "separator"
            section: actionItem.type == "title"
            icon: actionItem.icon ? actionItem.icon : null

            onClicked: {
                actionClicked(actionItem.actionId, actionItem.actionArgument);
            }
        }
    }
}
