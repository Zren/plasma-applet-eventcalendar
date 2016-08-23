import QtQuick 2.0
import org.kde.plasma.configuration 2.0

ConfigModel {
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
        name: i18n("Calendar")
        icon: "view-calendar-month"
        source: "config/ConfigCalendar.qml"
    }
    ConfigCategory {
        name: i18n("Agenda")
        icon: "view-calendar-agenda"
        source: "config/ConfigAgenda.qml"
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
}
