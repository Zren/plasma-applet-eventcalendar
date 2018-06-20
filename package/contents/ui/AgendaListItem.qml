import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

import "Shared.js" as Shared
import "../code/WeatherApi.js" as WeatherApi

GridLayout {
    id: agendaListItem
    columnSpacing: 0
    property var agendaItemEvents: model.events
    property date agendaItemDate: model.date
    property bool agendaItemIsToday: false
    function checkIfToday() {
        agendaItemIsToday = timeModel.currentTime && model.date ? Shared.isSameDate(timeModel.currentTime, model.date) : false
        // console.log('checkIfToday()', agendaListItem.agendaItemIsToday, timeModel.currentTime, model.date)
    }
    Component.onCompleted: agendaListItem.checkIfToday()
    Connections {
        target: timeModel
        onLoaded: agendaListItem.checkIfToday()
        onDateChanged: agendaListItem.checkIfToday()
    }
    property bool agendaItemInProgress: agendaItemIsToday
    property bool weatherOnRight: plasmoid.configuration.agendaWeatherOnRight

    Connections {
        target: agendaModel
        onPopulatingChanged: {
            if (!agendaModel.populating) {
                agendaListItem.reset()
            }
        }
    }
    function reset() {
        newEventForm.active = false
        agendaListItem.checkIfToday()
    }

    readonly property int itemOffset: agendaScrollView.getItemOffsetY(index)
    readonly property int scrollOffset: agendaScrollView.scrollY - itemOffset
    readonly property bool isCurrentItem: 0 <= scrollOffset && scrollOffset < height
    // onItemOffsetChanged: console.log(index, 'itemOffset', itemOffset)

    LinkRect {
        visible: agendaModel.showDailyWeather
        Layout.alignment: Qt.AlignTop
        Layout.column: weatherOnRight ? 2 : 0
        Layout.minimumWidth: appletConfig.agendaDateColumnWidth
        implicitWidth: itemWeatherColumn.implicitWidth
        onWidthChanged: {
            if (width > appletConfig.agendaDateColumnWidth) {
                appletConfig.agendaDateColumnWidth = width
            }
        }
        implicitHeight: itemWeatherColumn.implicitHeight

        readonly property int maxOffset: agendaListItem.height - height
        Layout.topMargin: agendaListItem.isCurrentItem ? Math.min(maxOffset, agendaListItem.scrollOffset) : 0

        ColumnLayout {
            id: itemWeatherColumn
            Layout.alignment: Qt.AlignTop
            spacing: 0
            anchors.horizontalCenter: parent.horizontalCenter

            FontIcon {
                visible: showWeather && plasmoid.configuration.agenda_weather_show_icon
                color: agendaItemIsToday ? inProgressColor : PlasmaCore.ColorScope.textColor
                source: weatherIcon
                height: appletConfig.agendaWeatherIconSize
                showOutline: plasmoid.configuration.show_outlines
                Layout.fillWidth: true
            }

            PlasmaComponents.Label {
                id: itemWeatherText
                visible: showWeather && plasmoid.configuration.agenda_weather_show_text
                text: weatherText
                color: agendaItemIsToday ? inProgressColor : PlasmaCore.ColorScope.textColor
                opacity: agendaItemIsToday ? 1 : 0.75
                font.weight: agendaItemIsToday ? inProgressFontWeight : Font.Normal
                horizontalAlignment: Text.AlignHCenter
            }

            PlasmaComponents.Label {
                id: itemWeatherTemps
                visible: showWeather
                text: tempHigh + '° | ' + tempLow + '°'
                color: agendaItemIsToday ? inProgressColor : PlasmaCore.ColorScope.textColor
                opacity: agendaItemIsToday ? 1 : 0.75
                font.weight: agendaItemIsToday ? inProgressFontWeight : Font.Normal
                horizontalAlignment: Text.AlignHCenter
            }
        }

        tooltipMainText: weatherDescription
        tooltipSubText: weatherNotes

        onLeftClicked: {
            // console.log('agendaItem.date.clicked', date)
            if (true) {
                // cfg_agenda_weather_clicked == "browser_viewcityforecast"
                WeatherApi.openCityUrl();
            }
        }
    }

    LinkRect {
        Layout.alignment: Qt.AlignTop
        Layout.column: weatherOnRight ? 0 : 1
        implicitWidth: appletConfig.agendaDateColumnWidth

        readonly property int maxOffset: agendaListItem.height - height
        Layout.topMargin: agendaListItem.isCurrentItem ? Math.min(maxOffset, agendaListItem.scrollOffset) : 0

        ColumnLayout {
            id: itemDateColumn
            anchors.left: parent.left
            anchors.right: parent.right
            anchors.leftMargin: appletConfig.agendaColumnSpacing
            anchors.rightMargin: appletConfig.agendaColumnSpacing
            spacing: 0

            PlasmaComponents.Label {
                id: itemDate
                text: Qt.formatDateTime(date, i18nc("agenda date format line 1", "MMM d"))
                color: agendaItemIsToday ? inProgressColor : PlasmaCore.ColorScope.textColor
                opacity: agendaItemIsToday ? 1 : 0.75
                font.pointSize: -1
                font.pixelSize: appletConfig.agendaFontSize
                font.weight: agendaItemIsToday ? inProgressFontWeight : Font.Normal
                height: paintedHeight
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignRight

                // MouseArea {
                //     anchors.fill: itemDateColumn
                //     onClicked: {
                //         newEventInput.forceActiveFocus()
                //     }
                // }
            }

            PlasmaComponents.Label {
                id: itemDay
                text: Qt.formatDateTime(date, i18nc("agenda date format line 2", "ddd"))
                color: agendaItemIsToday ? inProgressColor : PlasmaCore.ColorScope.textColor
                opacity: agendaItemIsToday ? 1 : 0.5
                font.pointSize: -1
                font.pixelSize: appletConfig.agendaFontSize
                font.weight: agendaItemIsToday ? inProgressFontWeight : Font.Normal
                height: paintedHeight
                Layout.fillWidth: true
                horizontalAlignment: Text.AlignRight
            }
        }

        onLeftClicked: {
            // console.log('agendaItem.date.leftClicked', date)
            if (false) {
                // cfg_agenda_date_clicked == "browser_newevent"
                Shared.openGoogleCalendarNewEventUrl(date);
            } else if (true) {
                // cfg_agenda_date_clicked == "agenda_newevent"
                newEventForm.active = !newEventForm.active
            }
        }
    }

    ColumnLayout {
        Layout.alignment: Qt.AlignTop | Qt.AlignLeft
        Layout.column: weatherOnRight ? 1 : 2
        spacing: 0
        Item {
            Layout.fillWidth: true
        }

        NewEventForm {
            id: newEventForm
            Layout.fillWidth: true
        }

        ColumnLayout {
            spacing: appletConfig.agendaRowSpacing
            Layout.fillWidth: true

            Repeater {
                model: agendaItemEvents

                delegate: AgendaEventItem {
                    id: agendaEventItem
                }
            }
        }

    }
}
