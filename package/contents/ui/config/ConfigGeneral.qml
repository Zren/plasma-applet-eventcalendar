
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

    property alias cfg_clock_mousewheel_up: clock_mousewheel_up.text
    property alias cfg_clock_mousewheel_down: clock_mousewheel_down.text
    property alias cfg_timer_repeats: timer_repeats.checked
    property alias cfg_timer_in_taskbar: timer_in_taskbar.checked
    property alias cfg_timer_ends_at: timer_ends_at.text

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
                level: 4
                text: i18n("Mouse Wheel")
                color: palette.text
            }
            Button {
                text: 'amixer (No UI)'
                onClicked: {
                    cfg_clock_mousewheel_up = 'amixer -q sset Master 10%+'
                    cfg_clock_mousewheel_down = 'amixer -q sset Master 10%-'
                }
            }
            Button {
                text: 'xdotool (UI) (sudo apt-get install xdotool)'
                onClicked: {
                    cfg_clock_mousewheel_up = 'xdotool key XF86AudioRaiseVolume'
                    cfg_clock_mousewheel_down = 'xdotool key XF86AudioLowerVolume'
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Label {
                    text: i18n("Mouse Wheel Up:")
                }
                TextField {
                    Layout.fillWidth: true
                    id: clock_mousewheel_up
                }
            }

            RowLayout {
                Layout.fillWidth: true
                Label {
                    text: i18n("Mouse Wheel Down:")
                }
                TextField {
                    Layout.fillWidth: true
                    id: clock_mousewheel_down
                }
            }
        }

        PlasmaExtras.Heading {
            visible: showDebug
            level: 2
            text: i18n("Timer")
            color: palette.text
        }
        Item {
            visible: showDebug
            width: height
            height: units.gridUnit / 2
        }
        ColumnLayout {
            RowLayout {
                visible: showDebug
                Layout.fillWidth: true
                Label {
                    text: i18n("timer_repeats:")
                }
                PlasmaComponents.Switch {
                    id: timer_repeats
                    Layout.fillWidth: true
                }
            }

            RowLayout {
                visible: showDebug
                Layout.fillWidth: true
                Label {
                    text: i18n("timer_in_taskbar:")
                }
                PlasmaComponents.Switch {
                    id: timer_in_taskbar
                    Layout.fillWidth: true
                }
            }

            RowLayout {
                visible: showDebug
                Layout.fillWidth: true
                Label {
                    text: i18n("timer_ends_at:")
                }
                TextField {
                    id: timer_ends_at
                    Layout.fillWidth: true
                }
            }
        }
    }
}