import QtQuick 2.0
import org.kde.plasma.configuration 2.0

ConfigModel {
    ConfigCategory {
        name: i18n("General")
        icon: "preferences-desktop-color"
        source: "config/ConfigGeneral.qml"
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
