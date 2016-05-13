
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
    
    property string cfg_mousewheel: 'run_commands'
    property alias cfg_mousewheel_up: mousewheel_up.text
    property alias cfg_mousewheel_down: mousewheel_down.text

    property bool showDebug: false

    SystemPalette {
        id: palette
    }

    function setCommands(up, down) {
        cfg_mousewheel = 'run_commands'
        mousewheelGroup_runcommands.checked = true
        cfg_mousewheel_up = up
        cfg_mousewheel_down = down
    }

    Layout.fillWidth: true

    ColumnLayout {
        id: pageColumn
        Layout.fillWidth: true

        ColumnLayout {
            PlasmaExtras.Heading {
                level: 3
                text: i18n("Mouse Wheel")
                color: palette.text
            }
            GroupBox {
                Layout.fillWidth: true

                ColumnLayout {
                    ExclusiveGroup { id: mousewheelGroup }

                    RadioButton {
                        id: mousewheelGroup_runcommands
                        exclusiveGroup: mousewheelGroup
                        checked: cfg_mousewheel == 'run_commands'
                        text: 'Run Commands'
                        onClicked: {
                            cfg_mousewheel = 'run_commands'
                        }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        Text { width: indentWidth } // indent
                        Label {
                            text: 'Scoll Up:'
                        }
                        TextField {
                            Layout.fillWidth: true
                            id: mousewheel_up
                        }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        Text { width: indentWidth } // indent
                        Label {
                            text: 'Scroll Down:'
                        }
                        TextField {
                            Layout.fillWidth: true
                            id: mousewheel_down
                        }
                    }

                    RadioButton {
                        exclusiveGroup: mousewheelGroup
                        checked: false
                        text: 'Volume (No UI) (amixer)'
                        onClicked: {
                            setCommands('amixer -q sset Master 10%+', 'amixer -q sset Master 10%-')
                        }
                    }

                    RadioButton {
                        exclusiveGroup: mousewheelGroup
                        checked: false
                        text: 'Volume (UI) (xdotool) (sudo apt-get install xdotool)'
                        onClicked: {
                            setCommands('xdotool key XF86AudioRaiseVolume', 'xdotool key XF86AudioLowerVolume')
                        }
                    }

                }
            }

        }
    }
}