import QtQuick 2.1
import QtQuick.Layouts 1.0
import QtQuick.Controls 1.0
import QtQuick.Controls.Styles.Plasma 2.0 as PlasmaStyles

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

Item {
    id: mediaController
    property bool disablePositionUpdate: false
    property bool keyPressed: false

    Item {
        anchors.fill: parent
        anchors.topMargin: seekSlider.height

        PlasmaComponents.ToolButton {
            anchors.fill: parent
            anchors.rightMargin: rightSide.width
            enabled: mpris2Source.canRaise
            onClicked: {
                mpris2Source.raise()
                if (plasmoid.hideOnWindowDeactivate) {
                    plasmoid.expanded = false
                }
            }

            Image {
                id: albumArt
                anchors.left: parent.left
                width: height
                height: parent.height
                source: mpris2Source.albumArt
                asynchronous: true
                fillMode: Image.PreserveAspectCrop
                sourceSize: Qt.size(width, height)
                visible: !!mpris2Source.track && status === Image.Ready
            }

            Column {
                id: leftSide
                anchors.fill: parent
                anchors.leftMargin: albumArt.width + 4
                // anchors.rightMargin: rightSide.width

                // MediaControllerCompact's style
                PlasmaComponents.Label {
                    id: track
                    width: parent.width
                    opacity: 0.9
                    height: parent.height / 2

                    elide: Text.ElideRight
                    text: mpris2Source.track
                }

                PlasmaComponents.Label {
                    id: artist
                    width: parent.width
                    opacity: 0.7
                    height: parent.height / 2

                    elide: Text.ElideRight
                    text: mpris2Source.artist
                }
            }
        }

        Row {
            id: rightSide
            width: childrenRect.width
            height: parent.height
            anchors.right: parent.right
            anchors.verticalCenter: parent.verticalCenter

            // Column {
            //     width: height
            //     height: parent.height
            //     visible: mpris2Source.canGoNext

            //     IconToolButton {
            //         width: parent.height
            //         height: parent.height / 2
            //         enabled: mpris2Source.canLoop
            //         source: {
            //             if (mpris2Source.isLoopingTrack) {
            //                 return "media-repeat-single"
            //             } else if (mpris2Source.isLoopingPlaylist) {
            //                 return "media-repeat-all"
            //             } else {
            //                 return "media-repeat-none"
            //             }
            //         }
            //         onClicked: mpris2Source.toggleLoopState()
            //     }
            //      IconToolButton {
            //         width: parent.height
            //         height: parent.height / 2
                    
            //         enabled: mpris2Source.canShuffle
            //         source: "shuffle"
            //         iconOpacity: mpris2Source.isShuffling ? 1 : 0.5
            //         onClicked: mpris2Source.toggleShuffle()
            //     }
            // }
            
            PlasmaComponents.ToolButton {
                iconSource: "media-skip-backward"
                width: height
                height: parent.height
                enabled: mpris2Source.canGoPrevious
                onClicked: {
                    seekSlider.value = 0 // Let the media start from beginning. Bug 362473 (org.kde.plasma.mediacontroller)
                    mpris2Source.previous()
                }
            }
            PlasmaComponents.ToolButton {
                iconSource: mpris2Source.isPlaying ? "media-playback-pause" : "media-playback-start"
                width: height
                height: parent.height
                enabled: mpris2Source.canControl
                onClicked: mpris2Source.playPause()
            }
            PlasmaComponents.ToolButton {
                iconSource: "media-skip-forward"
                width: height
                height: parent.height
                enabled: mpris2Source.canGoNext
                onClicked: {
                    seekSlider.value = 0 // Let the media start from beginning. Bug 362473 (org.kde.plasma.mediacontroller)
                    mpris2Source.next()
                }
            }
        }
    }

    PlasmaComponents.Slider {
        id: seekSlider
        anchors.left: parent.left
        anchors.top: parent.top
        anchors.right: parent.right
        height: config.mediaControllerSliderHeight
        enabled: mpris2Source.canSeek
        z: 999
        // style: PlasmaStyles.SliderStyle {
        //     handle: Item {}
        // }

        // MouseArea {
        //     id: seekSliderArea
        //     anchors.fill: parent
        //     hoverEnabled: true

        //     acceptedButtons: Qt.NoButton
        //     propagateComposedEvents: true
        // }
        opacity: hovered ? 1 : 0.75
        Behavior on opacity {
            NumberAnimation { duration: units.longDuration }
        }

        value: 0
        onValueChanged: {
            if (!mediaController.disablePositionUpdate) {
                // delay setting the position to avoid race conditions
                queuedPositionUpdate.restart()
            }
        }
        maximumValue: mpris2Source.length
        onMaximumValueChanged: mpris2Source.retrievePosition()

        Connections {
            target: mpris2Source

            onPositionChanged: {
                // we don't want to interrupt the user dragging the slider
                if (!seekSlider.pressed && !mediaController.keyPressed && !queuedPositionUpdate.running) {
                    // we also don't want passive position updates
                    mediaController.disablePositionUpdate = true
                    seekSlider.value = mpris2Source.position
                    mediaController.disablePositionUpdate = false
                }
            }
        }


        Timer {
            id: queuedPositionUpdate
            interval: 100
            onTriggered: mpris2Source.setPosition(seekSlider.value)
        }

        Timer {
            id: seekTimer
            interval: 1000
            repeat: true
            running: mpris2Source.isPlaying && plasmoid.expanded && !mediaController.keyPressed
            onTriggered: {
                // console.log(seekSlider.value, seekSlider.maximumValue,
                //     seekSlider.pressed ? 'pressed' : '',
                //     mediaController.disablePositionUpdate ? 'disablePositionUpdate' : '',
                //     mpris2Source.canSeek ? 'canSeek': '')
                
                // some players don't continuously update the seek slider position via mpris
                // add one second; value in microseconds
                if (!seekSlider.pressed) {
                    mediaController.disablePositionUpdate = true
                    if (seekSlider.value == seekSlider.maximumValue) {
                        mpris2Source.retrievePosition();
                    } else {
                        seekSlider.value += 1000000
                    }
                    mediaController.disablePositionUpdate = false
                }
            }
        }
    }
}