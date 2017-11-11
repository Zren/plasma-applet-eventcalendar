import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

import "../lib"

ConfigPage {
    id: page
    showAppletVersion: true

    property alias cfg_volumeUpDownSteps: volumeUpDownSteps.value
    property alias cfg_showVolumeTickmarks: showVolumeTickmarks.checked
    // property alias cfg_showOpenKcmAudioVolume: showOpenKcmAudioVolume.checked
    // property alias cfg_showOpenPavucontrol: showOpenPavucontrol.checked
    property alias cfg_moveAllAppsOnSetDefault: moveAllAppsOnSetDefault.checked
    property alias cfg_closeOnSetDefault: closeOnSetDefault.checked
    property alias cfg_showMediaController: showMediaController.checked
    property alias cfg_showMediaTimeElapsed: showMediaTimeElapsed.checked
    property alias cfg_showMediaTimeLeft: showMediaTimeLeft.checked
    property alias cfg_showMediaTotalDuration: showMediaTotalDuration.checked
    property alias cfg_showOsd: showOsd.checked
    property alias cfg_volumeChangeFeedback: volumeChangeFeedback.checked

    GroupBox {
        Layout.fillWidth: true
        title: i18n("Media Keys")

        ColumnLayout {

            RowLayout {
                Label {
                    text: i18n("Volume Up/Down Steps:")
                }
                SpinBox {
                    id: volumeUpDownSteps
                    minimumValue: 1
                }
                Label {
                    text: i18n("One step = %1%", Math.round(1/volumeUpDownSteps.value * 100))
                }
            }

        }
    }

    GroupBox {
        Layout.fillWidth: true
        title: i18n("Mixer")

        ColumnLayout {

            CheckBox {
                enabled: false
                id: showVolumeTickmarks
                checked: true
                text: i18n("Show Ticks every 10%")
            }

            RowLayout {
                Label {
                    text: i18n("Volume Boost")
                }
                SpinBox {
                    enabled: false
                    id: volumeBoostMaxVolume
                    minimumValue: 100
                    value: 150
                    maximumValue: 1000
                    stepSize: 10
                    suffix: i18nd("plasma_applet_org.kde.plasma.volume", "%")
                }
            }
            


        }
    }

    ExclusiveGroup { id: volumeSliderThemeGroup }
    GroupBox {
        Layout.fillWidth: true
        title: i18n("Volume Slider Theme")

        ColumnLayout {
            RadioButton {
                text: i18n("Desktop Theme (%1)", theme.themeName)
                exclusiveGroup: volumeSliderThemeGroup
                enabled: false
                // checked: plasmoid.configuration.volumeSliderTheme == "desktoptheme"
                // onClicked: plasmoid.configuration.volumeSliderTheme = "desktoptheme"
            }
            RadioButton {
                text: i18n("Color Theme (Default Look)")
                exclusiveGroup: volumeSliderThemeGroup
                // checked: plasmoid.configuration.volumeSliderTheme == "colortheme"
                // onClicked: plasmoid.configuration.volumeSliderTheme = "colortheme"
                checked: plasmoid.configuration.volumeSliderTheme == "desktoptheme"
                onClicked: plasmoid.configuration.volumeSliderTheme = "desktoptheme"
            }
            
            RadioButton {
                text: i18n("Light Blue on Grey (Default Look)")
                exclusiveGroup: volumeSliderThemeGroup
                checked: plasmoid.configuration.volumeSliderTheme == "default"
                onClicked: plasmoid.configuration.volumeSliderTheme = "default"
            }
        }
    }

    // GroupBox {
    //     Layout.fillWidth: true
    //     title: 'Context Menu'

    //     ColumnLayout {

    //         CheckBox {
    //             id: showOpenKcmAudioVolume
    //             text: 'KDE Audio Volume'
    //         }

    //         CheckBox {
    //             id: showOpenPavucontrol
    //             text: 'pavucontrol (PulseAudio Control) (Can do Audio Boost)'
    //         }

    //         RowLayout {
    //             Text { width: 24 } // indent
    //             Text {
    //                 font.family: 'monospace'
    //                 text: 'sudo apt-get install pavucontrol'
    //             }
    //         }

    //     }
    // }

    GroupBox {
        Layout.fillWidth: true
        title: i18n("Options")

        ColumnLayout {

            CheckBox {
                id: moveAllAppsOnSetDefault
                text: i18n("Move all Apps to device when setting default device (when set in with the context menu)")
            }

            CheckBox {
                id: closeOnSetDefault
                text: i18n("Close the popup after setting a default device")
            }

            CheckBox {
                id: showOsd
                text: i18n("Show OSD on when changing the volume.")
            }

            CheckBox {
                id: volumeChangeFeedback
                text: i18n("Volume Feedback: Play popping noise when changing the volume.")
            }

        }
    }

    GroupBox {
        Layout.fillWidth: true
        title: i18n("Media Controller")

        ColumnLayout {

            CheckBox {
                id: showMediaController
                text: i18n("Show Media Controller")
            }

            ConfigComboBox {
                id: appDescriptionControl
                configKey: "mediaControllerLocation"
                label: i18n("Position")
                model: [
                    { value: "top", text: i18n("Top") },
                    { value: "bottom", text: i18n("Bottom") },
                ]
            }

            CheckBox {
                id: showMediaTimeElapsed
                text: i18n("Show Time Elapsed")
            }

            CheckBox {
                id: showMediaTimeLeft
                text: i18n("Show Time Left")
            }

            CheckBox {
                id: showMediaTotalDuration
                text: i18n("Show Total Duration")
            }

        }
    }

    GroupBox {
        Layout.fillWidth: true
        title: i18n("Keyboard Shortcuts")

        ColumnLayout {
            id: shortcutsTable
            Layout.fillWidth: true

            Label {
                text: i18n("Set the Global Shortcut in the Keyboard Shortcuts tab.")
                wrapMode: Text.Wrap
            }

            Label {} // Whitespace

            Repeater {
                property var shortcuts: [
                    {
                        "label": i18n("Global Shortcut"),
                        "keySequence": plasmoid.globalShortcut,
                    },
                    {
                        "label": i18n("Selection: Select Previous Stream"),
                        "keySequence": "Left",
                    },
                    {
                        "label": i18n("Selection: Select Next Stream"),
                        "keySequence": "Right",
                    },
                    {
                        "label": i18n("Selection: Increase Volume"),
                        "keySequence": "Up",
                    },
                    {
                        "label": i18n("Selection: Decrease Volume"),
                        "keySequence": "Down",
                    },
                    {
                        "label": i18n("Selection: Make Default Device"),
                        "keySequence": "Enter",
                    },
                    {
                        "label": i18n("Selection: Toggle Mute"),
                        "keySequence": "M",
                    },
                ]

                Component.onCompleted: {
                    for (var i = 0; i <= 10; i++) {
                        shortcuts.push({
                            "label": i18n("Selection: Set Volume to %1%", i*10),
                            "keySequence": i < 10 ? "" + i : "",
                        })
                        model = shortcuts
                    }
                }


                RowLayout {
                    Layout.fillWidth: true
                    Label {
                        text: modelData.keySequence
                        
                        Layout.minimumWidth: 100 * units.devicePixelRatio
                    }
                    Label {
                        text: modelData.label
                        font.bold: true
                    }
                }

            }
        }
    }

    
}
