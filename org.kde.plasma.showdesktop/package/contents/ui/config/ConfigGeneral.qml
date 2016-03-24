
import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.calendar 2.0 as PlasmaCalendar
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

Item {
    id: generalPage

    implicitWidth: pageColumn.implicitWidth
    implicitHeight: pageColumn.implicitHeight

    property alias cfg_mousewheel_up: mousewheel_up.text
    property alias cfg_mousewheel_down: mousewheel_down.text

    property bool showDebug: false

    SystemPalette {
        id: palette
    }

    Layout.fillWidth: true

    ColumnLayout {
        id: pageColumn
        Layout.fillWidth: true

        PlasmaExtras.Heading {
            level: 2
            text: i18n("Clock")
            color: palette.text
        }
        Item {
            width: height
            height: units.gridUnit / 2
        }
        ColumnLayout {
            PlasmaExtras.Heading {
                level: 3
                text: i18n("Mouse Wheel")
                color: palette.text
            }
            Button {
                text: 'amixer (No UI)'
                onClicked: {
                    cfg_mousewheel_up = 'amixer -q sset Master 10%+'
                    cfg_mousewheel_down = 'amixer -q sset Master 10%-'
                }
            }
            RowLayout {
                Button {
                    text: 'xdotool (UI)'
                    onClicked: {
                        cfg_mousewheel_up = 'xdotool key XF86AudioRaiseVolume'
                        cfg_mousewheel_down = 'xdotool key XF86AudioLowerVolume'
                    }
                }
                Label {
                    text: 'sudo apt-get install xdotool'
                }
            }
            RowLayout {
                Layout.fillWidth: true
                Label {
                    text: i18n("Mouse Wheel Up:")
                }
                TextField {
                    Layout.fillWidth: true
                    id: mousewheel_up
                }
            }
            RowLayout {
                Layout.fillWidth: true
                Label {
                    text: i18n("Mouse Wheel Down:")
                }
                TextField {
                    Layout.fillWidth: true
                    id: mousewheel_down
                }
            }
        }
    }
}