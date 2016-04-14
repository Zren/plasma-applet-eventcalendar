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

    property bool anyWidgetVisible: plasmoid.configuration.widget_show_spacer ||  plasmoid.configuration.widget_show_meteogram ||  plasmoid.configuration.widget_show_timer
    width: 400 + 10 + 400
    height: 400 + (anyWidgetVisible ? 10 + 100 : 0)


    PlasmaCore.DataSource {
        id: dataSource
        engine: "time"
        connectedSources: ["Local"]
        interval: plasmoid.configuration.clock_show_seconds ? 1000 : 60000
        intervalAlignment: plasmoid.configuration.clock_show_seconds ? PlasmaCore.Types.NoAlignment : PlasmaCore.Types.AlignToMinute
    }
    
    Plasmoid.toolTipMainText: Qt.formatTime(dataSource.data["Local"]["DateTime"])
    Plasmoid.toolTipSubText: Qt.formatDate(dataSource.data["Local"]["DateTime"], Qt.locale().dateFormat(Locale.LongFormat))
    
    FontLoader {
        source: "../fonts/weathericons-regular-webfont.ttf"
    }

    // org.kde.plasma.mediacontrollercompact
    PlasmaCore.DataSource {
        id: executeSource
        engine: "executable"
        connectedSources: []
        onNewData: {
            //we get new data when the process finished, so we can remove it
            disconnectSource(sourceName)
        }
    }
    function exec(cmd) {
        //Note: we assume that 'cmd' is executed quickly so that a previous call
        //with the same 'cmd' has already finished (otherwise no new cmd will be
        //added because it is already in the list)
        executeSource.connectSource(cmd)
    }

    property Component clockComponent: ClockView {
        id: clock

        formFactor: plasmoid.formFactor
        cfg_clock_24h: plasmoid.configuration.clock_24h
        cfg_clock_fontfamily: plasmoid.configuration.clock_fontfamily
        cfg_clock_timeformat: plasmoid.configuration.clock_timeformat
        cfg_clock_timeformat_2: plasmoid.configuration.clock_timeformat_2
        cfg_clock_line_2: plasmoid.configuration.clock_line_2
        cfg_clock_line_2_height_ratio: plasmoid.configuration.clock_line_2_height_ratio
        cfg_clock_line_1_bold: plasmoid.configuration.clock_line_1_bold
        cfg_clock_line_2_bold: plasmoid.configuration.clock_line_2_bold
        

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

            // http://dev.man-online.org/man1/xdotool/
            // xmodmap -pke
            // keycode 122 = XF86AudioLowerVolume NoSymbol XF86AudioLowerVolume
            // keycode 123 = XF86AudioRaiseVolume NoSymbol XF86AudioRaiseVolume
            onWheel: {
                var delta = wheel.angleDelta.y || wheel.angleDelta.x;
                
                // if (delta > 0) {
                //     topOverlap += 1
                //     bottomOverlap += 1
                // } else {
                //     topOverlap -= 1
                //     bottomOverlap -= 1
                // }
                // return;

                wheelDelta += delta;
                // Magic number 120 for common "one click"
                // See: http://qt-project.org/doc/qt-5/qml-qtquick-wheelevent.html#angleDelta-prop
                while (wheelDelta >= 120) {
                    wheelDelta -= 120;
                    root.exec(plasmoid.configuration.clock_mousewheel_up)
                }
                while (wheelDelta <= -120) {
                    wheelDelta += 120;
                    root.exec(plasmoid.configuration.clock_mousewheel_down)
                }
            }
        }
    }

    property Component popupComponent: PopupView {
        id: popup
        config: plasmoid.configuration
        cfg_clock_24h: plasmoid.configuration.clock_24h
        cfg_widget_show_spacer: plasmoid.configuration.widget_show_spacer
        cfg_widget_show_meteogram: plasmoid.configuration.widget_show_meteogram
        cfg_widget_show_timer: plasmoid.configuration.widget_show_timer
        cfg_agenda_weather_show_icon: plasmoid.configuration.agenda_weather_show_icon
        cfg_agenda_weather_icon_height: plasmoid.configuration.agenda_weather_icon_height
        cfg_agenda_weather_show_text: plasmoid.configuration.agenda_weather_show_text
        cfg_agenda_breakup_multiday_events: plasmoid.configuration.agenda_breakup_multiday_events
        cfg_month_show_border: plasmoid.configuration.month_show_border


        property bool isExpanded: plasmoid.expanded
        onIsExpandedChanged: {
            console.log('isExpanded', isExpanded);
            if (isExpanded) {
                today = dataSource.data["Local"]["DateTime"] || new Date()
                monthViewDate = today
                selectedDate = today
                updateHeight();
                updateWeather();
            }
        }

        Connections {
            target: plasmoid.configuration
            onClock_24hChanged: { updateUI() }
            onAgenda_breakup_multiday_eventsChanged: { updateUI() }
            onCalendar_id_listChanged: { updateEvents() }
            onAccess_tokenChanged: { updateEvents() }
            onWeather_app_idChanged: { updateWeather(true) }
            onWeather_city_idChanged: { updateWeather(true) }
            onWidget_show_spacerChanged: { updateHeight() }
            onWidget_show_meteogramChanged: {
                updateHeight();
                if (plasmoid.configuration.widget_show_meteogram) {
                    updateHourlyWeather();
                }
            }
            onWidget_show_timerChanged: { updateHeight() }
        }

    }


    Plasmoid.preferredRepresentation: plasmoid.containmentType == PlasmaCore.ContainmentType.DesktopContainment ? Plasmoid.fullRepresentation : Plasmoid.compactRepresentation
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
        plasmoid.setAction("KCMFormats", i18n("Set Time Format..."));
    }
}
