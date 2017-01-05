import QtQuick 2.1
import QtQuick.Controls.Private 1.0 as QtQuickControlsPrivate

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

PlasmaComponents.ToolButton {
    property alias source: icon.source
    property alias iconOpacity: icon.opacity
    property bool controlHovered: hovered && !(QtQuickControlsPrivate.Settings.hasTouchScreen && QtQuickControlsPrivate.Settings.isMobile)
    PlasmaCore.IconItem {
        id: icon
        anchors.fill: parent
        visible: valid
        active: parent.controlHovered
        colorGroup: parent.controlHovered || !parent.flat ? PlasmaCore.Theme.ButtonColorGroup : PlasmaCore.ColorScope.colorGroup
    }
}
