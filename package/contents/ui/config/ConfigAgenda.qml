import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Layouts 1.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

import ".."
import "../lib"

ConfigPage {
    id: page

    property alias cfg_widget_show_agenda: widget_show_agenda.checked
    property bool cfg_agendaWeatherOnRight: false
    property alias cfg_agenda_weather_show_icon: agenda_weather_show_icon.checked
    property alias cfg_agenda_weather_icon_height: agenda_weather_icon_height.value
    property alias cfg_agenda_weather_show_text: agenda_weather_show_text.checked
    property bool cfg_agenda_breakup_multiday_events: false
    property alias cfg_agenda_newevent_remember_calendar: agenda_newevent_remember_calendar.checked
    property alias cfg_show_outlines: show_outlines.checked
    property bool cfg_twoColumns: true

    property int indentWidth: 24 * units.devicePixelRatio

    CheckBox {
        Layout.fillWidth: true
        id: widget_show_agenda
        text: i18n("Show agenda")
    }

    ConfigSection {
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

    ConfigSection {
        ConfigSpinBox {
            configKey: 'agenda_fontSize'
            before: i18n("Font Size:")
            suffix: i18n("px")
            after: i18n(" (0px = <b>System Settings > Fonts > General</b>)")
        }
    }

    ConfigSection {
        RowLayout {
            CheckBox {
                id: agenda_weather_show_icon
                checked: true
                text: i18n("Weather Icon")
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
            Text { width: indentWidth } // Indent
            CheckBox {
                id: show_outlines
                text: i18n("Icon Outline")
            }
        }

        CheckBox {
            id: agenda_weather_show_text
            text: i18n("Weather Text")
        }

        LabeledRowLayout {
            label: i18n("Position:")
            ExclusiveGroup { id: agendaWeatherOnRightGroup }
            RadioButton {
                text: i18n("Left")
                exclusiveGroup: agendaWeatherOnRightGroup
                checked: !cfg_agendaWeatherOnRight
                onClicked: cfg_agendaWeatherOnRight = false
            }
            RadioButton {
                text: i18n("Right")
                exclusiveGroup: agendaWeatherOnRightGroup
                checked: cfg_agendaWeatherOnRight
                onClicked: cfg_agendaWeatherOnRight = true
            }
        }

        LabeledRowLayout {
            label: i18n("Click Weather:")
            ExclusiveGroup { id: agenda_weather_clickGroup }
            RadioButton {
                text: i18n("Open City Forecast In Browser")
                exclusiveGroup: agenda_weather_clickGroup
                checked: true
            }
        }
    }

    ConfigSection {
        LabeledRowLayout {
            label: i18n("Click Date:")
            ExclusiveGroup { id: agenda_date_clickGroup }
            RadioButton {
                text: i18n("Open New Event In Browser")
                exclusiveGroup: agenda_date_clickGroup
                enabled: false
            }
            RadioButton {
                text: i18n("Open New Event Form")
                exclusiveGroup: agenda_date_clickGroup
                checked: true
            }
        }
    }

    ConfigSection {
        LabeledRowLayout {
            label: i18n("Click Event:")
            ExclusiveGroup { id: agenda_event_clickGroup }
            RadioButton {
                text: i18n("Open Event In Browser")
                checked: true
                exclusiveGroup: agenda_event_clickGroup
            }
        }
    }


    ConfigSection {
        LabeledRowLayout {
            label: i18n("Show multi-day events:")
            ExclusiveGroup {
                id: agenda_breakup_multiday_eventsGroup
            }
            RadioButton {
                text: i18n("On all days")
                checked: cfg_agenda_breakup_multiday_events
                exclusiveGroup: agenda_breakup_multiday_eventsGroup
                onClicked: {
                    cfg_agenda_breakup_multiday_events = true
                }
            }
            RadioButton {
                text: i18n("Only on the first and current day")
                checked: !cfg_agenda_breakup_multiday_events
                exclusiveGroup: agenda_breakup_multiday_eventsGroup
                onClicked: {
                    cfg_agenda_breakup_multiday_events = false
                }
            }
        }
    }

    ConfigSection {
        CheckBox {
            id: agenda_newevent_remember_calendar
            text: i18n("Remember selected calendar in New Event Form")
        }
    }

    ConfigSection {
        title: i18n("Current Month")

        CheckBox {
            enabled: false
            checked: true
            text: i18n("Always show next 14 days")
        }
        CheckBox {
            enabled: false
            checked: false
            text: i18n("Hide completed events")
        }
        CheckBox {
            enabled: false
            checked: true
            text: i18n("Show all events of the current day (including completed events)")
        }
    }

    AppletConfig { id: config }
    ColorGrid {
        title: i18n("Colors")

        ConfigColor {
            configKey: 'agenda_inProgressColor'
            label: i18n("In Progress")
            defaultColor: config.agendaInProgressColorDefault
        }
    }

}
