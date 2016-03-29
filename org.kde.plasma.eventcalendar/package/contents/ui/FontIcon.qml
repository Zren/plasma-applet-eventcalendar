import QtQuick 2.2
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

// Technique based on plasma-applet-weather-widget
// https://github.com/kotelnik/plasma-applet-weather-widget/blob/320ed5661475f176116e1785476dc51710494b86/package/contents/code/icons.js
Item {
    width: 16
    height: 16
    property string source: ""
    property alias color: iconText.color
    
    // FontLoader {
    //     source: "../fonts/weathericons-regular-webfont.ttf"
    // }

    PlasmaComponents.Label {
        id: iconText
        text: ''
        color: PlasmaCore.ColorScope.textColor

        font.family: "weathericons"
        font.pointSize: -1
        font.pixelSize: parent.height
        anchors.centerIn: parent
    }

    function getIconCode(name) {
        var codeByName = {
            'weather-clear': '\uf00d',
            'weather-few-clouds': '\uf002',
            'weather-clouds': '\uf041',
            'weather-overcast': '\uf013',
            'weather-showers-scattered': '\uf009',
            'weather-showers': '\uf019',
            'weather-storm': '\uf01e',
            'weather-snow': '\uf01b',
            'weather-fog': '\uf014',

            // Night
            'weather-clear-night': '\uf02e',
        };
        return codeByName[name];
    }

    function setIcon() {
        if (!source) return;
        
        var code = getIconCode(source);
        iconText.text = code ? code : '';
    }

    onSourceChanged: {
        setIcon()
    }

    Component.onCompleted: {
        setIcon()
    }
}
