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

    property alias cfg_widget_show_agenda: widget_show_agenda.checked
    property alias cfg_agenda_weather_show_icon: agenda_weather_show_icon.checked
    property alias cfg_agenda_weather_icon_height: agenda_weather_icon_height.value
    property alias cfg_agenda_weather_show_text: agenda_weather_show_text.checked
    property bool cfg_agenda_breakup_multiday_events: false
    property alias cfg_agenda_newevent_remember_calendar: agenda_newevent_remember_calendar.checked
    property alias cfg_show_outlines: show_outlines.checked
    property bool cfg_twoColumns: true

    SystemPalette {
        id: palette
    }

    ColumnLayout {
        Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                
        CheckBox {
            Layout.fillWidth: true
            id: widget_show_agenda
            text: "Show agenda"
        }

        GroupBox {
            Layout.fillWidth: true
            ColumnLayout {
                ExclusiveGroup { id: layoutGroup }
                RadioButton {
                    text: i18n("Agenda above the month (Single Column)")
                    exclusiveGroup: layoutGroup
                    enabled: cfg_widget_show_agenda
                    checked: !cfg_twoColumns
                    onClicked: cfg_twoColumns = false
                }
                RadioButton {
                    text: i18n("Agenda to the left (Two Columns)")
                    exclusiveGroup: layoutGroup
                    enabled: cfg_widget_show_agenda
                    checked: cfg_twoColumns
                    onClicked: cfg_twoColumns = true
                }
            }
        }

        GroupBox {
            Layout.fillWidth: true

            ColumnLayout {

                RowLayout {
                    CheckBox {
                        id: agenda_weather_show_icon
                        checked: true
                        text: "Weather Icon"
                    }
                    Slider {
                        id: agenda_weather_icon_height
                        minimumValue: 12
                        maximumValue: 48
                        stepSize: 1
                        value: 24
                    }
                    Label {
                        text: cfg_agenda_weather_icon_height + 'px'
                    }

                }

                RowLayout {
                    Text { width: 24 }
                    CheckBox {
                        id: show_outlines
                        text: "Icon Outline"
                    }
                }

                CheckBox {
                    id: agenda_weather_show_text
                    text: "Weather Text"
                }

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


        GroupBox {
            Layout.fillWidth: true

            RowLayout {
                Label {
                    text: "Show multi-day events:"
                    Layout.alignment: Qt.AlignTop | Qt.AlignLeft
                }
                ColumnLayout {
                    ExclusiveGroup {
                        id: agenda_breakup_multiday_eventsGroup
                    }
                    RadioButton {
                        text: "On all days"
                        checked: cfg_agenda_breakup_multiday_events
                        exclusiveGroup: agenda_breakup_multiday_eventsGroup
                        onClicked: {
                            cfg_agenda_breakup_multiday_events = true
                        }
                    }
                    RadioButton {
                        text: "Only on the first and current day"
                        checked: !cfg_agenda_breakup_multiday_events
                        exclusiveGroup: agenda_breakup_multiday_eventsGroup
                        onClicked: {
                            cfg_agenda_breakup_multiday_events = false
                        }
                    }
                }
            }
        }

        GroupBox {
            Layout.fillWidth: true

            CheckBox {
                id: agenda_newevent_remember_calendar
                text: "Remember selected calendar in New Event Form"
            }
        
        }

        GroupBox {
            Layout.fillWidth: true
            title: 'Current Month'

            ColumnLayout {
                CheckBox {
                    enabled: false
                    checked: true
                    text: "Always show next 14 days"
                }
                CheckBox {
                    enabled: false
                    checked: false
                    text: "Hide completed events"
                }
                CheckBox {
                    enabled: false
                    checked: true
                    text: "Show all events of the current day (including completed events)"
                }
            }
        }

        GroupBox {
            visible: false
            Layout.fillWidth: true
            title: 'Colors'

            ColumnLayout {
                RowLayout {
                    Label {
                        text: "Event In Progress:"
                    }
                    TextField {
                        id: agenda_event_inprogress_color
                        placeholderText: theme.highlightColor
                    }
                    Button {
                        text: "Highlight"
                        onClicked: {
                            agenda_event_inprogress_color.text = 'highlightColor'
                        }
                    }
                    Button {
                        text: "Normal"
                        onClicked: {
                            agenda_event_inprogress_color.text = 'textColor'
                        }
                    }
                }
            }
        }


    }
}