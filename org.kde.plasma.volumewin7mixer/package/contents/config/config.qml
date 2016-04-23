import QtQuick 2.0
import org.kde.plasma.configuration 2.0

ConfigModel {
    ConfigCategory {
        name: i18n("Applet")
        icon: "preferences-desktop-color"
        source: "config/ConfigApplet.qml"
    }
}
