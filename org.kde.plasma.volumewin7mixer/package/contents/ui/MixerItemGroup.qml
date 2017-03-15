import QtQuick 2.0
import QtQuick.Layouts 1.0
import QtQuick.Controls 1.0
import QtQuick.Controls.Private 1.0 as QtQuickControlsPrivate
import QtQuick.Controls.Styles.Plasma 2.0 as PlasmaStyles

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

import org.kde.plasma.private.volume 0.1

GroupBox {
    id: mixerItemGroup

    signal onTitleButtonClicked()

    style: PlasmaStyles.GroupBoxStyle {
        id: groupBoxStyle

        panel: Item {
            anchors.fill: parent

            PlasmaComponents.ToolButton {
                id: label
                anchors.top: parent.top
                anchors.left: parent.left
                anchors.right: parent.right
                text: control.title
                // width: mixerItemGroup.mixerItemWidth
                property var name
                height: Math.max(theme.defaultFont.pixelSize, pinButton.height)
                onClicked: mixerItemGroup.onTitleButtonClicked()

                style: PlasmaStyles.ToolButtonStyle {
                    label: PlasmaComponents.Label {
                        id: label
                        // anchors.verticalCenter: parent.verticalCenter
                        Layout.minimumWidth: implicitWidth
                        text: QtQuickControlsPrivate.StyleHelpers.stylizeMnemonics(control.text)
                        font: control.font || theme.defaultFont
                        visible: control.text != ""
                        Layout.fillWidth: true
                        color: control.hovered || !flat ? theme.buttonTextColor : PlasmaCore.ColorScope.textColor
                        horizontalAlignment: Text.AlignLeft
                        elide: Text.ElideRight
                    }
                }
            }

            PlasmaCore.FrameSvgItem {
                id: frame
                anchors.fill: parent
                imagePath: "widgets/frame"
                prefix: "plain"
                visible: !control.flat
                colorGroup: PlasmaCore.ColorScope.colorGroup
                Component.onCompleted: {
                    groupBoxStyle.padding.left = frame.margins.left
                    groupBoxStyle.padding.top = label.height
                    groupBoxStyle.padding.right = frame.margins.right
                    groupBoxStyle.padding.bottom = frame.margins.bottom
                }
            }
        }
    }
    property alias view: view
    property alias spacing: view.spacing
    property alias model: view.model
    property alias delegate: view.delegate
    property int mixerItemWidth: config.mixerItemWidth
    property int volumeSliderWidth: config.volumeSliderWidth
    property string mixerGroupType: ''
    visible: view.count > 0
    
    ListView {
        id: view
        width: Math.max(childrenRect.width, mixerItemGroup.mixerItemWidth) // At least 1 mixer item wide
        height: parent.height
        spacing: 10
        boundsBehavior: Flickable.StopAtBounds
        orientation: ListView.Horizontal

        delegate: MixerItem {
            // width: mixerItemWidth
            mixerItemWidth: mixerItemGroup.mixerItemWidth
            volumeSliderWidth: mixerItemGroup.volumeSliderWidth
            mixerItemType: mixerItemGroup.mixerGroupType
        }
    }
}
