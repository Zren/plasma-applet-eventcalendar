import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.calendar 2.0 as PlasmaCalendar
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

ColumnLayout {
    id: page
    property bool showDebug: false

    SystemPalette {
        id: palette
    }

    ColumnLayout {
        Layout.alignment: Qt.AlignTop | Qt.AlignLeft

        GroupBox {
            Layout.fillWidth: true

            ColumnLayout {

                RowLayout {
                    Label {
                        text: "Click Weather:"
                        Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                    }
                    ColumnLayout {
                        ExclusiveGroup { id: agenda_weather_clickGroup }
                        RadioButton {
                            text: "Open City Forecast In Browser"
                            exclusiveGroup: agenda_weather_clickGroup
                            checked: true
                        }
                    }
                }

                RowLayout {
                    CheckBox {
                        enabled: false
                        checked: true
                        text: "Weather Icon"
                    }
                    Slider {
                        id: agenda_weather_icon_size
                        enabled: false
                        minimumValue: 12
                        maximumValue: 48
                        stepSize: 1
                        value: 24
                    }
                    Label {
                        text: agenda_weather_icon_size.value + 'px'
                    }

                }

                RowLayout {
                    CheckBox {
                        enabled: false
                        checked: false
                        text: "Weather Text"
                    }
                }
            }
        }

        GroupBox {
            Layout.fillWidth: true

            RowLayout {
                Label {
                    text: "Click Date:"
                    Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                }
                ColumnLayout {
                    ExclusiveGroup { id: agenda_date_clickGroup }
                    RadioButton {
                        text: "Open New Event In Browser"
                        exclusiveGroup: agenda_date_clickGroup
                        enabled: false
                    }
                    RadioButton {
                        text: "Open New Event Form"
                        exclusiveGroup: agenda_date_clickGroup
                        checked: true
                    }
                }
            }
        }

        GroupBox {
            Layout.fillWidth: true

            RowLayout {
                Label {
                    text: "Click Event:"
                    Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                }
                ColumnLayout {
                    ExclusiveGroup { id: agenda_event_clickGroup }
                    RadioButton {
                        text: "Open Event In Browser"
                        checked: true
                        exclusiveGroup: agenda_event_clickGroup
                    }
                }
            }
        }


    }
}