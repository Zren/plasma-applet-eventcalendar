import QtQuick 2.1
import org.kde.plasma.configuration 2.0
import org.kde.plasma.calendar 2.0 as PlasmaCalendar

ConfigModel {
    id: configModel

    ConfigCategory {
        name: i18n("General")
        icon: "clock"
        source: "config/ConfigGeneral.qml"
    }
    // ConfigCategory {
    //     name: i18n("Clock")
    //     icon: "clock"
    //     source: "config/ConfigClock.qml"
    // }
    ConfigCategory {
        name: i18n("Timezones")
        icon: "preferences-system-time"
        source: "config/ConfigTimezones.qml"
    }
    ConfigCategory {
        name: i18n("Calendar")
        icon: "view-calendar"
        source: "config/ConfigCalendar.qml"
    }
    ConfigCategory {
        name: i18n("Agenda")
        icon: "view-calendar-agenda"
        source: "config/ConfigAgenda.qml"
    }
    ConfigCategory {
        name: i18n("Events")
        icon: "view-calendar-week"
        source: "config/ConfigEvents.qml"
    }
    ConfigCategory {
        name: i18n("ICalendar (.ics)")
        icon: "text-calendar"
        source: "config/ConfigICal.qml"
        visible: plasmoid.configuration.debugging
    }
    ConfigCategory {
        name: i18n("Google Calendar")
        icon: "google-chrome"
        source: "config/ConfigGoogleCalendar.qml"
    }
    ConfigCategory {
        name: i18n("Weather")
        icon: "weather-clear"
        source: "config/ConfigWeather.qml"
    }
    ConfigCategory {
        name: i18n("Advanced")
        icon: "applications-development"
        source: "lib/ConfigAdvanced.qml"
        visible: plasmoid.configuration.debugging
    }

    property Instantiator __eventPlugins: Instantiator {
        model: PlasmaCalendar.EventPluginsManager.model
        delegate: ConfigCategory {
            name: model.display
            icon: model.decoration
            source: model.configUi
            visible: plasmoid.configuration.enabledCalendarPlugins.indexOf(model.pluginPath) > -1
        }

        onObjectAdded: configModel.appendCategory(object)
        onObjectRemoved: configModel.removeCategory(object)
    }
}
