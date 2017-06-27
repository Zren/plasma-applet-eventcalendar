import QtQuick 2.0
import QtQuick.Layouts 1.0
import QtQuick.Controls 1.0
import QtQuick.Controls.Private 1.0 as QtQuickControlsPrivate
import QtQuick.Controls.Styles.Plasma 2.0 as PlasmaStyles

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

import org.kde.plasma.private.volume 0.1

import "lib"

GroupBox {
    id: mixerItemGroup

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


                onClicked: contextMenu.showRelative()
                ContextMenu {
                    id: contextMenu
                    visualParent: label
                    placement: PlasmaCore.Types.BottomPosedLeftAlignedPopup

                    onBeforeOpen: {
                        function filterStreamName(streamName) {
                            return function() {
                                console.log('menuItem.clicked', streamName)
                                view.model.filters.push({
                                    role: 'name',
                                    value: streamName,
                                })
                                //TODO: Find function that will force the model to reparse the filterCallback
                                // https://github.com/KDE/plasma-framework/blob/master/src/declarativeimports/core/datamodel.h
                                // view.model.invalidateFilter() // Not exposed
                                // view.model.invalidate() // Just empties the model
                            }
                        }
                        // console.log('onBeforeOpen', view.model, view.model.count)
                        for (var i = 0; i < view.model.count; i++) {
                            var stream = view.model.get(i)
                            // console.log(mixerItemGroup.model, i, stream)
                            var menuItem = menu.newMenuItem()
                            menuItem.text = stream.PulseObject.name
                            menuItem.checkable = true
                            menuItem.checked = true
                            menuItem.enabled = false
                            // menuItem.clicked.connect(filterStreamName(stream.PulseObject.name))
                        }
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
        spacing: 0
        boundsBehavior: Flickable.StopAtBounds
        orientation: ListView.Horizontal

        delegate: MixerItem {
            // width: mixerItemWidth
            mixerItemWidth: mixerItemGroup.mixerItemWidth
            volumeSliderWidth: mixerItemGroup.volumeSliderWidth
            mixerItemType: mixerItemGroup.mixerGroupType
            showDefaultDeviceIndicator: mixerItemGroup.model.count > 1
        }

        currentIndex: -1

        highlight: Rectangle {
            color: "transparent"
            anchors.fill: view.currentItem
            border.width: 1
            border.color: config.selectedStreamOutline

            
            SequentialAnimation on border.color {
                loops: Animation.Infinite
                ColorAnimation {
                    from: config.selectedStreamOutline
                    to: config.selectedStreamOutlinePulse
                    duration: 1000
                }
                ColorAnimation {
                    from: config.selectedStreamOutlinePulse
                    to: config.selectedStreamOutline
                    duration: 1000
                }
            }
        }
    }
}
