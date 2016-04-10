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

    // http://api.kde.org/frameworks-api/frameworks5-apidocs/plasma-framework/html/SliderStyle_8qml_source.html
    style: PlasmaStyles.SliderStyle {

        handle: Item {}

        groove: PlasmaCore.FrameSvgItem {
            id: groove
            imagePath: "widgets/slider"
            prefix: "groove"
            // height: implicitHeight
            height: control.orientation == Qt.Horizontal ? control.height :  control.width
            colorGroup: PlasmaCore.ColorScope.colorGroup
            opacity: control.enabled ? 1 : 0.6
    
            PlasmaCore.FrameSvgItem {
                id: highlight
                imagePath: "widgets/slider"
                prefix: "groove-highlight"
                height: groove.height
    
                width: styleData.handlePosition
                anchors.verticalCenter: parent.verticalCenter
                colorGroup: PlasmaCore.ColorScope.colorGroup
    
                visible: value > 0
            }
        }
    }
}