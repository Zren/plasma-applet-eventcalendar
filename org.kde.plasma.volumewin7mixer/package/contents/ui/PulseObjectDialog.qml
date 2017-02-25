import QtQuick 2.2
import QtQuick.Window 2.1
import QtQuick.Controls 1.2
import QtQuick.Controls.Styles 1.2
import QtQuick.Layouts 1.0
import QtQuick.Dialogs 1.0

Window {
    property var pulseObject
    width: 600
    height: 600
    title: i18n('%1 - Audio Volume', pulseObject.name)


    ColumnLayout {
        anchors.fill: parent

        // Label {
        //     text: pulseObject.name
        // }

        TableView {
            id: tableView
            Layout.fillWidth: true
            Layout.fillHeight: true

            model: ListModel {}

            TableViewColumn {
                role: "key"
            }
            TableViewColumn {
                role: "value"
                width: 400
            }

            style: TableViewStyle {} // Ignore panel theme (which might be black bg)
            
            section.property: 'section'
            section.delegate: Label {
                text: section
                font.bold: true
                font.pixelSize: 16
            }
        }
    }

    function findEntry(section, key) {
        for (var i = 0; i < tableView.model.count; i++) {
            var item = tableView.model.get(i)
            if (item.section === section && item.key === key) {
                return i
            }
        }
        return -1
    }
    
    function addEntry(key, value, section) {
        tableView.model.append({
            key: key,
            value: '' + value,
            section: ('' + section) || '',
        })
    }

    function setEntry(key, value, section) {
        // Scan for existing property
        var entryIndex = findEntry(section, key)
        if (entryIndex >= 0) {
            var item = tableView.model.get(entryIndex)
            var newValueStr = '' + value
            if (item.value !== newValueStr) {
                // valueChanged
                console.log(key, value)
                tableView.model.setProperty(entryIndex, "value", newValueStr)
            }
        } else {
            // Property doesn't yet exist.
            console.log(key, value)
            addEntry(key, value, section)
        }
    }

    function addPulseObjectEntry(key, section) {
        if (typeof pulseObject[key] !== 'undefined') {
            setEntry(key, pulseObject[key], section)
        }
    }

    function addPortEntry(i, port, key, section) {
        if (typeof port[key] !== 'undefined') {
            setEntry('port[' + i + '].' + key, port[key], section)
        }
    }

    function addPropertiesEntries(obj, section) {
        if (typeof obj.properties !== 'undefined') {
            for (var key in obj.properties) {
                setEntry(key, obj.properties[key], section)
            }
        }
    }

    function update() {
        addPulseObjectEntry('name', '')

        // https://github.com/KDE/plasma-pa/blob/master/src/pulseobject.h
        addPulseObjectEntry('index', 'PulseObject')
        addPulseObjectEntry('iconName', 'PulseObject')
        // addPulseObjectEntry('properties', 'PulseObject')

        // https://github.com/KDE/plasma-pa/blob/master/src/volumeobject.h
        addPulseObjectEntry('volume', 'VolumeObject')
        addPulseObjectEntry('muted', 'VolumeObject')
        addPulseObjectEntry('hasVolume', 'VolumeObject')
        addPulseObjectEntry('volumeWriteable', 'VolumeObject')
        addPulseObjectEntry('channels', 'VolumeObject')
        addPulseObjectEntry('channelVolumes', 'VolumeObject') // QVariant(QList<qlonglong>) <= How do I expose the QList (and it's contents)?

        // if (typeof pulseObject.channelVolumes !== 'undefined') {
        //     for (var i = 0; i < pulseObject.channels.length; i++) {
        //         var section = 'Device.channels[' + i + ']'
        //         addEntry('channels[' + i + '].name', pulseObject.channels[i], section)
        //         // addEntry('channels[' + i + '].volume', pulseObject.channelVolumes[i], section) // Doesn't work since channelVolumes is a QVariant...
        //     }
        // }

        // https://github.com/KDE/plasma-pa/blob/master/src/device.h
        addPulseObjectEntry('state', 'Device')
        // addPulseObjectEntry('name', 'Device')
        addPulseObjectEntry('description', 'Device')
        addPulseObjectEntry('cardIndex', 'Device')
        // addPulseObjectEntry('ports', 'Device')
        addPulseObjectEntry('activePortIndex', 'Device')
        addPulseObjectEntry('default', 'Device')

        if (typeof pulseObject.ports !== 'undefined') {
            for (var i = 0; i < pulseObject.ports.length; i++) {
                var port = pulseObject.ports[i];
                var section = 'Device.ports[' + i + ']'
                // https://github.com/KDE/plasma-pa/blob/master/src/profile.h
                addPortEntry(i, port, 'name', section)
                addPortEntry(i, port, 'description', section)
                addPortEntry(i, port, 'priority', section)

                // https://github.com/KDE/plasma-pa/blob/master/src/port.h
                addPortEntry(i, port, 'available', section)

                // https://github.com/KDE/plasma-pa/blob/master/src/card.h
                addPropertiesEntries(port, section)
            }
        }
        
        
        // https://github.com/KDE/plasma-pa/blob/master/src/stream.h
        // addPulseObjectEntry('name', 'Stream')
        // addPulseObjectEntry('client', 'Stream')
        addPulseObjectEntry('virtualStream', 'Stream')
        addPulseObjectEntry('deviceIndex', 'Stream')
        addPulseObjectEntry('corked', 'Stream')

        // https://github.com/KDE/plasma-pa/blob/master/src/client.h
        // addPulseObjectEntry('name', 'Client')

        //
        addPropertiesEntries(pulseObject, 'PulseObject.properties')
    }

    Component.onCompleted: {
        update()
    }

    Timer {
        running: true
        repeat: true
        interval: 1000
        onTriggered: update()
    }
}
