import QtQuick 2.0
import QtQuick.Layouts 1.0
import QtQuick.Controls 1.0
import QtQuick.Controls.Styles.Plasma 2.0 as PlasmaStyles

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

import org.kde.plasma.private.volume 0.1

Item {
    id: root
    Layout.minimumHeight: units.gridUnit * 12
    Layout.preferredHeight: units.gridUnit * 24
    Layout.minimumWidth: 200
    Layout.preferredWidth: mixerItemRow.childrenRect.width
    property string displayName: i18n("Audio Volume")

    property int mixerItemWidth: 100
    property int volumeSliderWidth: 50

    property alias appsModel: appsModel
    property alias sourceModel: sourceModel
    property alias sinkModel: sinkModel

    width: mixerItemRow.childrenRect.width
    height: Layout.preferredHeight

    onWidthChanged: {
        // Layout.minimumWidth = width
        Layout.preferredWidth = width
    }


    Rectangle {
        color: PlasmaCore.ColorScope.backgroundColor
        anchors.fill: parent
    }


    // https://github.com/KDE/plasma-pa/tree/master/src/kcm/package/contents/ui
    PulseObjectFilterModel {
        id: appsModel
        sourceModel: SinkInputModel {}
    }
    SourceModel {
        id: sourceModel
    }
    SinkModel {
        id: sinkModel
    }



    RowLayout {
        id: mixerItemRow
        anchors.right: parent.right
        width: childrenRect.width
        height: parent.height
        spacing: 10
        // onWidthChanged: {
        //     // parent.width = width

        //     console.log(parent.width, width)
        
        //     parent.width = Math.max(width, parent.width)

        //     console.log(parent.width)
        // }

        MixerItemGroup {
            height: parent.height
            title: 'Apps'
    
            model: appsModel
            delegate: MixerItem {
                width: root.mixerItemWidth
                volumeSliderWidth: root.volumeSliderWidth
                icon: {
                    var client = PulseObject.client;
                    // Virtual streams don't have a valid client object, force a default icon for them
                    if (client) {
                        if (client.properties['application.icon_name']) {
                            return client.properties['application.icon_name'].toLowerCase();
                        } else if (client.properties['application.process.binary']) {
                            var binary = client.properties['application.process.binary'].toLowerCase()
                            // FIXME: I think this should do a reverse-desktop-file lookup
                            // or maybe appdata could be used?
                            // At any rate we need to attempt mapping binary to desktop file
                            // such that we could get the icon.
                            if (binary === 'chrome' || binary === 'chromium') {
                                return 'google-chrome';
                            }
                            return binary;
                        }
                        return 'unknown';
                    } else {
                        return 'audio-card';
                    }
                }

            }
        }

        MixerItemGroup {
            height: parent.height
            title: 'Mics'
    
            model: sourceModel
            delegate: MixerItem {
                width: root.mixerItemWidth
                volumeSliderWidth: root.volumeSliderWidth
                icon: Volume > 0 ? 'mic-on' : 'mic-off'
            }
        }

        MixerItemGroup {
            height: parent.height
            title: 'Speakers'
    
            model: sinkModel
            mixerItemIcon: 'speaker'
        }
    }
    
}