import QtQuick 2.0
import QtQuick.Layouts 1.0
import QtQuick.Controls 1.0

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

PlasmaComponents.ToolButton {
    id: iconLabelButton
    height: childrenRect.height
    property alias labelText: textLabel.rawText
    property alias iconItemSource: icon.source
    property alias iconItemOverlays: icon.overlays
    property alias iconItemHeight: icon.height

    // ColumnLayout {
    Column {
        id: iconLabelButtonRow
        width: parent.width
        // spacing: 0
        
        PlasmaCore.IconItem {
            id: icon
            width: parent.width

            // From ToolButtonStyle:
            active: iconLabelButton.hovered
            colorGroup: iconLabelButton.hovered || !iconLabelButton.flat ? PlasmaCore.Theme.ButtonColorGroup : PlasmaCore.ColorScope.colorGroup
        }

        Label {
            id: textLabel
            width: parent.width
            // Layout.fillWidth: true

            property string rawText: ''
            text: rawText + '\n'
            function updateLineCount() {
                if (lineCount == 1) {
                    text = rawText + '\n'
                } else if (truncated) {
                    text = rawText
                }
            }
            onLineCountChanged: updateLineCount()
            onTruncatedChanged: updateLineCount()
            color: iconLabelButton.hovered ? theme.buttonTextColor : PlasmaCore.ColorScope.textColor
            opacity: iconLabelButton.hovered ? 1 : 0.6
            wrapMode: Text.Wrap
            elide: Text.ElideRight
            maximumLineCount: 2
            horizontalAlignment: Text.AlignHCenter
        }
    }
}
