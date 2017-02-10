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

    Logger {
        id: logger
        name: 'eventcalendar'
        // showDebug: true
    }

    AppletConfig { id: appletConfig }

    property alias dataSource: timeModel.dataSource
    property alias currentTime: timeModel.currentTime
    property alias eventModel: eventModel
    property alias weatherModel: weatherModel
    property alias agendaModel: agendaModel

    TimeModel { id: timeModel }
    EventModel { id: eventModel }
    WeatherModel { id: weatherModel }
    AgendaModel {
        id: agendaModel
        eventModel: eventModel
        weatherModel: weatherModel
        Component.onCompleted: logger.debug('AgendaModel.onCompleted')
    }

    FontLoader {
        source: "../fonts/weathericons-regular-webfont.ttf"
    }

    Plasmoid.toolTipMainText: Qt.formatTime(currentTime, Qt.locale().timeFormat(Locale.LongFormat))
    Plasmoid.toolTipSubText: Qt.formatDate(currentTime, Qt.locale().dateFormat(Locale.LongFormat))
    
    // org.kde.plasma.mediacontrollercompact
    PlasmaCore.DataSource {
        id: executable
        engine: "executable"
        connectedSources: []
        onNewData: disconnectSource(sourceName) // cmd finished
        function exec(cmd) {
            connectSource(cmd)
        }
    }

    property Component clockComponent: ClockView {
        id: clock

        currentTime: timeModel.currentTime

        // org.kde.plasma.volume
        MouseArea {
            id: mouseArea
            anchors.fill: parent

            property int wheelDelta: 0

            onClicked: {
                if (mouse.button == Qt.LeftButton) {
                    plasmoid.expanded = !plasmoid.expanded;
                }
            }

            onWheel: {
                var delta = wheel.angleDelta.y || wheel.angleDelta.x;
                wheelDelta += delta;
                
                // Magic number 120 for common "one click"
                // See: http://qt-project.org/doc/qt-5/qml-qtquick-wheelevent.html#angleDelta-prop
                while (wheelDelta >= 120) {
                    wheelDelta -= 120;
                    executable.exec(plasmoid.configuration.clock_mousewheel_up)
                }
                while (wheelDelta <= -120) {
                    wheelDelta += 120;
                    executable.exec(plasmoid.configuration.clock_mousewheel_down)
                }
            }
        }
    }

    property Component popupComponent: PopupView {
        id: popup

        eventModel: root.eventModel
        weatherModel: root.weatherModel
        // agendaModel: root.agendaModel

        // If pin is enabled, we need to add some padding around the popup unless
        // * we're a desktop widget (no need)
        // * the timer widget is enabled since there's room in the top right
        property bool isPinVisible: {
            // plasmoid.location == PlasmaCore.Types.Floating when using plasmawindowed and when used as a desktop widget.
            return plasmoid.location != PlasmaCore.Types.Floating // && plasmoid.configuration.widget_show_pin
        }
        padding: {
            if (isPinVisible && !(plasmoid.configuration.widget_show_timer || plasmoid.configuration.widget_show_meteogram)) {
                return units.largeSpacing;
            } else {
                return 0;
            }
        }

        property bool isExpanded: plasmoid.expanded
        onIsExpandedChanged: {
            logger.debug('isExpanded', isExpanded);
            if (isExpanded) {
                updateToday()
                updateWeather()
            }
        }

        function updateToday() {
            setToday(root.currentTime)
        }

        function setToday(d) {
            logger.debug('setToday', d)
            today = d
            // console.log(root.timezone, dataSource.data[root.timezone]["DateTime"])
            logger.debug('currentTime', root.currentTime)
            monthViewDate = today
            selectedDate = today
            scrollToSelection()
        }

        Connections {
            target: plasmoid.configuration
            onClock_24hChanged: { updateUI() }
            onAgenda_breakup_multiday_eventsChanged: { updateUI() }
            onCalendar_id_listChanged: { updateEvents() }
            onAccess_tokenChanged: { updateEvents() }
            onWeather_app_idChanged: { updateWeather(true) }
            onWeather_city_idChanged: { updateWeather(true) }
            onWeather_canada_city_idChanged: { updateWeather(true) }
            onWeather_serviceChanged: { updateWeather(true) }
            onWeather_unitsChanged: { updateWeather(true) }
            onMeteogram_hoursChanged: { updateWeather() }
            onWidget_show_meteogramChanged: {
                if (plasmoid.configuration.widget_show_meteogram) {
                    updateHourlyWeather();
                }
            }
        }

        Connections {
            target: timeModel
            onDateChanged: {
                popup.updateToday()
                logger.debug('root.onDateChanged', root.currentTime, popup.today)
            }
        }

        // Allows the user to keep the calendar open for reference
        PlasmaComponents.ToolButton {
            visible: isPinVisible
            anchors.right: parent.right
            width: Math.round(units.gridUnit * 1.25)
            height: width
            checkable: true
            iconSource: "window-pin"
            onCheckedChanged: plasmoid.hideOnWindowDeactivate = !checked
        }

    }

    // Plasmoid.backgroundHints: PlasmaCore.Types.NoBackground
    property bool isDesktopContainment: plasmoid.location == PlasmaCore.Types.Floating
    Plasmoid.preferredRepresentation: isDesktopContainment ? Plasmoid.fullRepresentation : Plasmoid.compactRepresentation
    Plasmoid.compactRepresentation: clockComponent
    Plasmoid.fullRepresentation: popupComponent

    function action_KCMClock() {
        KCMShell.open("clock");
    }

    function action_KCMFormats() {
        KCMShell.open("formats");
    }

    Component.onCompleted: {
        plasmoid.setAction("KCMClock", i18n("Adjust Date and Time..."), "preferences-system-time");
        plasmoid.setAction("KCMFormats", i18n("Set Locale..."), "preferences-desktop-locale");
    }

    // Timer {
    //     interval: 400
    //     running: true
    //     onTriggered: plasmoid.expanded = true
    // }
}
