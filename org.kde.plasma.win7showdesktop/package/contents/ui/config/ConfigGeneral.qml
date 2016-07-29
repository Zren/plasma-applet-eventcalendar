
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
    
    property string cfg_click_action: 'showdesktop'
    property alias cfg_click_command: click_command.text
    
    property string cfg_mousewheel_action: 'run_commands'
    property alias cfg_mousewheel_up: mousewheel_up.text
    property alias cfg_mousewheel_down: mousewheel_down.text

    property bool showDebug: false
    property int indentWidth: 24

    SystemPalette {
        id: palette
    }

    function setMouseWheelCommands(up, down) {
        cfg_mousewheel_action = 'run_commands'
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
                text: i18n("Click")
                color: palette.text
            }
            GroupBox {
                Layout.fillWidth: true

                ColumnLayout {
                    ExclusiveGroup { id: clickGroup }

                    RadioButton {
                        exclusiveGroup: clickGroup
                        checked: cfg_click_action == 'showdesktop'
                        text: 'Show Desktop'
                        onClicked: {
                            cfg_click_action = 'showdesktop'
                        }
                    }

                    RadioButton {
                        exclusiveGroup: clickGroup
                        checked: cfg_click_action == 'minimizeall'
                        text: 'Minimize All'
                        onClicked: {
                            cfg_click_action = 'minimizeall'
                        }
                    }

                    RadioButton {
                        id: clickGroup_runcommand
                        exclusiveGroup: clickGroup
                        checked: cfg_click_action == 'run_command'
                        text: 'Run Command'
                        onClicked: {
                            cfg_click_action = 'run_command'
                        }
                    }
                    RowLayout {
                        Layout.fillWidth: true
                        Text { width: indentWidth } // indent
                        TextField {
                            Layout.fillWidth: true
                            id: click_command
                        }
                    }
                }
            }

        }

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
                        checked: cfg_mousewheel_action == 'run_commands'
                        text: 'Run Commands'
                        onClicked: {
                            cfg_mousewheel_action = 'run_commands'
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
                            setMouseWheelCommands('amixer -q sset Master 10%+', 'amixer -q sset Master 10%-')
                        }
                    }

                    RadioButton {
                        exclusiveGroup: mousewheelGroup
                        checked: false
                        text: 'Volume (UI) (qdbus)'
                        property string upCommand:   'qdbus org.kde.kglobalaccel /component/kmix invokeShortcut "increase_volume"'
                        property string downCommand: 'qdbus org.kde.kglobalaccel /component/kmix invokeShortcut "decrease_volume"'
                        onClicked: {
                            setMouseWheelCommands(upCommand, downCommand)
                        }
                    }

                    RadioButton {
                        exclusiveGroup: mousewheelGroup
                        checked: false
                        text: 'Switch Desktop (qdbus)'
                        property string upCommand:   'qdbus org.kde.kglobalaccel /component/kwin invokeShortcut "Switch One Desktop to the Left"'
                        property string downCommand: 'qdbus org.kde.kglobalaccel /component/kwin invokeShortcut "Switch One Desktop to the Right"'
                        onClicked: {
                            setMouseWheelCommands(upCommand, downCommand)
                        }
                    }
                }
            }

        }
    }
}