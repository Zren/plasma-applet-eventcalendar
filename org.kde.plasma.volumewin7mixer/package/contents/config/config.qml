import QtQuick 2.0
import org.kde.plasma.configuration 2.0

ConfigModel {
    ConfigCategory {
        name: i18nd("plasma_applet_org.kde.plasma.volume", "General")
        icon: "plasma"
        source: "config/ConfigApplet.qml"
    }
    // ConfigCategory {
    //     name: "Stream Restore"
    //     icon: "document-save-symbolic"
    //     source: "config/ConfigStreamRestore.qml"
    // }
}
