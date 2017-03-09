import QtQuick 2.0
import QtQuick.Layouts 1.0
import QtQuick.Controls 1.0
import QtQuick.Controls.Styles.Plasma 2.0 as PlasmaStyles

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

import org.kde.plasma.private.volume 0.1

// http://api.kde.org/frameworks-api/frameworks5-apidocs/plasma-framework/html/Slider_8qml_source.html
PlasmaComponents.Slider {
    id: slider
    orientation: Qt.Vertical
    tickmarksEnabled: true
    property bool isVolumeBoosted: value > 66000 // 100% is 65863.68, not 65536... Bleh. Just trigger at a round number.
    property bool isBoostable: maximumValue > 66000
    // onValueChanged: {
    //     console.log('onValueChanged', value)
    // }


    // http://api.kde.org/frameworks-api/frameworks5-apidocs/plasma-framework/html/SliderStyle_8qml_source.html
    style: PlasmaStyles.SliderStyle {

        handle: Item {}

        groove: Rectangle {
            id: groove
            height: control.width
            opacity: control.enabled ? 1 : 0.6
            color: theme.buttonBackgroundColor
    
            Rectangle {
                id: highlight
                height: groove.height
    
                width: styleData.handlePosition
                anchors.verticalCenter: parent.verticalCenter
                color: isVolumeBoosted ? negativeColor.negativeTextColor : theme.highlightColor
                // onColorChanged: {
                //     console.log('onColorChanged', color, '//', value, isVolumeBoosted, negativeColor.negativeTextColor, theme.highlightColor)
                // }
    
                visible: value > 0

                PlasmaCore.ColorScope {
                    id: negativeColor
                }
            }
        }

        tickmarks: Repeater {
            // width/height and x/y is reversed since it's Vertical

            id: repeater
            model: (slider.isBoostable ? 15 : 10) + 1 // 0% .. 100% by 10 = 11 ticks (or ...150% = 16 ticks)
            // model: slider.tickmarkModel
            width: control.height 
            height: control.width

            Rectangle {
                color: theme.textColor == theme.buttonBackgroundColor ? theme.backgroundColor : theme.textColor
                // border.width: 1
                // border.color: theme.backgroundColor
                // width: 3
                width: 1
                height: {
                    if (index == 0) {
                        return 0; // 0% has no tick
                    } else if (index % 15 == 0) {
                        return control.width*4/5; // 150%
                    } else if (index % 10 == 0) {
                        return control.width*3/5; // 100%
                    } else if (index % 5 == 0) {
                        return control.width*2/5; // 50%
                    } else {
                        return control.width*1/5; // 10%, 20%, ... have short ticks
                    }
                }
                y: control.width - height
                x: {
                    if (index == 0) { // Align tick at very bottom to it's bottom.
                        return 0
                    } else if (index == repeater.count-1) { // Align tick at very top to it's top.
                        return repeater.width - width
                    } else {
                        //Position ticklines from styleData.handleWidth to width - styleData.handleWidth/2
                        //position them at an half handle width increment
                        return styleData.handleWidth / 2 + index * ((repeater.width - styleData.handleWidth) / (repeater.count>1 ? repeater.count-1 : 1)) - 1
                    }
                }

            }
       }
    }
}
