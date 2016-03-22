import QtQuick 2.0
import QtQuick.Layouts 1.1

import org.kde.plasma.plasmoid 2.0
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras
import org.kde.plasma.calendar 2.0 as PlasmaCalendar

import org.kde.kquickcontrolsaddons 2.0 // KCMShell

Item {
    id: root

    width: units.gridUnit * 10
    height: units.gridUnit * 4

    Plasmoid.preferredRepresentation: Plasmoid.compactRepresentation

    Plasmoid.toolTipMainText: Qt.formatTime(dataSource.data["Local"]["DateTime"])
    Plasmoid.toolTipSubText: Qt.formatDate(dataSource.data["Local"]["DateTime"], Qt.locale().dateFormat(Locale.LongFormat))

    PlasmaCore.DataSource {
        id: dataSource
        engine: "time"
        connectedSources: ["Local"]
        interval: 60000
        intervalAlignment: PlasmaCore.Types.AlignToMinute
    }
    
    FontLoader {
        source: "../fonts/weathericons-regular-webfont.ttf"
    }

    Plasmoid.compactRepresentation: ClockView {
        id: clock
    }
    
    Plasmoid.fullRepresentation: PopupView {
        id: popup
        today: dataSource.data["Local"]["DateTime"]
        config: plasmoid.configuration

        property bool isExpanded: plasmoid.expanded

        onIsExpandedChanged: {
            console.log('isExpanded', isExpanded);
            if (isExpanded) {
                monthViewDate = today
                // update();
            }
        }
    }   

    function action_KCMClock() {
        KCMShell.open("clock");
    }

    function action_KCMFormats() {
        KCMShell.open("formats");
    }

    Component.onCompleted: {
        plasmoid.setAction("KCMClock", i18n("Adjust Date and Time..."), "preferences-system-time");
        plasmoid.setAction("KCMFormats", i18n("Set Time Format..."));
    }
}
