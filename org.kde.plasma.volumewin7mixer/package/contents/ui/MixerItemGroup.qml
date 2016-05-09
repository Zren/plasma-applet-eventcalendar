import QtQuick 2.0
import QtQuick.Layouts 1.0
import QtQuick.Controls 1.0
import QtQuick.Controls.Styles.Plasma 2.0 as PlasmaStyles

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

import org.kde.plasma.private.volume 0.1

GroupBox {
    style: PlasmaStyles.GroupBoxStyle {}
    property alias view: view
    property alias spacing: view.spacing
    property alias model: view.model
    property alias delegate: view.delegate
    property int mixerItemWidth: 100
    property int volumeSliderWidth: 50
    property string mixerGroupType: ''
    visible: view.count > 0

    Text {
        text: parent.title
        color: PlasmaCore.ColorScope.textColor
        Layout.fillWidth: true
        horizontalAlignment: Text.AlignHCenter
    }
    
    ListView {
        id: view
        width: Math.max(childrenRect.width, mixerItemWidth) // At least 1 mixer item wide
        height: parent.height
        spacing: 10
        boundsBehavior: Flickable.StopAtBounds
        orientation: ListView.Horizontal

        delegate: MixerItem {
            width: mixerItemWidth
            volumeSliderWidth: volumeSliderWidth
            mixerItemType: mixerGroupType
        }
    }
}
