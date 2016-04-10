import QtQuick 2.0
import QtQuick.Layouts 1.0

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

import org.kde.plasma.private.volume 0.1

Item {
    PlasmaExtras.ScrollArea {
        id: scrollView;

        anchors {
            fill: parent
            rightMargin: 16
        }

        ColumnLayout {
            property int maximumWidth: scrollView.viewport.width
            width: maximumWidth
            Layout.maximumWidth: maximumWidth

            Header {
                Layout.fillWidth: true
                visible: sinkView.count > 0
                text: i18n("Playback Devices")
            }
            ListView {
                id: sinkView

                Layout.fillWidth: true
                Layout.minimumHeight: contentHeight
                Layout.maximumHeight: contentHeight

                model: SinkModel {
                    id: sinkModel
                }
                boundsBehavior: Flickable.StopAtBounds;
                delegate: SinkListItem {}
            }

            Header {
                Layout.fillWidth: true
                visible: sourceView.count > 0
                text: i18n("Capture Devices")
            }
            ListView {
                id: sourceView

                Layout.fillWidth: true
                Layout.minimumHeight: contentHeight
                Layout.maximumHeight: contentHeight

                model: SourceModel {
                    id: sourceModel
                }
                boundsBehavior: Flickable.StopAtBounds;
                delegate: SourceListItem {}
            }
        }
    }
}