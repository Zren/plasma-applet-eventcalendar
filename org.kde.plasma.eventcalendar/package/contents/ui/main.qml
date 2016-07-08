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
        cfg_clock_maxheight: plasmoid.configuration.clock_maxheight
        

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
                wheelDelta += delta;
                
                // if (delta > 0) {
                //     topOverlap += 1
                //     bottomOverlap += 1
                // } else {
                //     topOverlap -= 1
                //     bottomOverlap -= 1
                // }
                // return;

                if (plasmoid.configuration.clock_mousewheel == 'resize_clock') {
                    if (delta > 0) {
                        cfg_clock_maxheight += 1
                    } else {
                        cfg_clock_maxheight = Math.max(0, cfg_clock_maxheight - 1)
                    }
                // } else if (plasmoid.configuration.clock_mousewheel == 'run_commands') {
                } else {
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
    }

    property Component popupComponent: PopupView {
        id: popup
        config: plasmoid.configuration
        cfg_clock_24h: plasmoid.configuration.clock_24h
        cfg_widget_show_meteogram: plasmoid.configuration.widget_show_meteogram
        cfg_widget_show_timer: plasmoid.configuration.widget_show_timer
        cfg_widget_show_agenda: plasmoid.configuration.widget_show_agenda
        cfg_widget_show_calendar: plasmoid.configuration.widget_show_calendar
        cfg_timer_repeats: plasmoid.configuration.timer_repeats
        cfg_timer_sfx_enabled: plasmoid.configuration.timer_sfx_enabled
        cfg_timer_sfx_filepath: plasmoid.configuration.timer_sfx_filepath
        cfg_agenda_weather_show_icon: plasmoid.configuration.agenda_weather_show_icon
        cfg_agenda_weather_icon_height: plasmoid.configuration.agenda_weather_icon_height
        cfg_agenda_weather_show_text: plasmoid.configuration.agenda_weather_show_text
        cfg_agenda_breakup_multiday_events: plasmoid.configuration.agenda_breakup_multiday_events
        cfg_agenda_newevent_remember_calendar: plasmoid.configuration.agenda_newevent_remember_calendar
        cfg_agenda_newevent_last_calendar_id: plasmoid.configuration.agenda_newevent_last_calendar_id
        cfg_month_show_border: plasmoid.configuration.month_show_border
        cfg_month_show_weeknumbers: plasmoid.configuration.month_show_weeknumbers
        cfg_month_eventbadge_type: plasmoid.configuration.month_eventbadge_type
        cfg_events_pollinterval: plasmoid.configuration.events_pollinterval

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
            console.log('isExpanded', isExpanded);
            if (isExpanded) {
                today = dataSource.data["Local"]["DateTime"] || new Date()
                monthViewDate = today
                selectedDate = today
                scrollToSelection()
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
            onWeather_unitsChanged: { updateWeather(true) }
            onWidget_show_meteogramChanged: {
                if (plasmoid.configuration.widget_show_meteogram) {
                    updateHourlyWeather();
                }
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
        plasmoid.setAction("KCMFormats", i18n("Set Locale..."), "preferences-desktop-locale");
    }
}
