import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1

import "shared.js" as Shared
import "../code/WeatherApi.js" as WeatherApi
import "../code/DebugFixtures.js" as DebugFixtures

Item {
    id: agendaView

    //anchors.margins: units.largeSpacing
    property int spacing: units.largeSpacing
    property alias agendaListView: agendaListView

    property color inProgressColor: appletConfig.agendaInProgressColor
    property int inProgressFontWeight: Font.Bold

    signal newEventFormOpened(var agendaItem, var newEventCalendarId)
    signal submitNewEventForm(var calendarId, var date, string text)

    property alias agendaModel: agendaListView.model

    Connections {
        target: eventModel
        onEventCreated: {
            notificationManager.createNotification({
                appName: i18n("Event Calendar"),
                appIcon: "resource-calendar-insert",
                // expireTimeout: 10000,
                summary: data.summary,
                body: Shared.formatEventDuration(data, {
                    relativeDate: timeModel.currentTime,
                    clock24h: appletConfig.clock24h,
                })
            })
        }
        onEventDeleted: {
            logger.logJSON('AgendaView.onEventDeleted', data)
            notificationManager.createNotification({
                appName: i18n("Event Calendar"),
                appIcon: "user-trash-symbolic",
                // expireTimeout: 10000,
                summary: data.summary,
                body: Shared.formatEventDuration(data, {
                    relativeDate: timeModel.currentTime,
                    clock24h: appletConfig.clock24h,
                })
            })
        }
    }
    
    ListView {
        id: agendaListView
        // model: ListModel {}
        model: root.agendaModel
        anchors.fill: parent
        clip: true
        spacing: 10
        boundsBehavior: Flickable.StopAtBounds

        // Don't bother garbage collecting
        // GC or Reloading the weather images is very slow.
        cacheBuffer: 1000

        delegate: AgendaListItem {}
    }

    // TODO: properly detect when all events have completed loading
    Timer {
        id: scrollToIndexTimer
        property int itemIndex: -1
        interval: 400 // Give events time to populate
        onTriggered: agendaListView.positionViewAtIndex(itemIndex, ListView.Beginning)
        function scrollTo(i) {
            itemIndex = i
            restart()
        }
    }

    function scrollToTop() {
        agendaListView.positionViewAtBeginning()
    }

    function scrollToDate(date) {
        for (var i = 0; i < agendaModel.count; i++) {
            var agendaItem = agendaModel.get(i);
            if (Shared.isSameDate(date, agendaItem.date)) {
                agendaListView.positionViewAtIndex(i, ListView.Beginning);
                scrollToIndexTimer.scrollTo(i)
                return;
            } else if (Shared.isDateEarlier(date, agendaItem.date)) {
                // If the date is smaller than the current agendaItem.date, scroll to the previous agendaItem.
                if (i > 0) {
                    agendaListView.positionViewAtIndex(i-1, ListView.Beginning);
                    scrollToIndexTimer.scrollTo(i-1)
                } else {
                    agendaListView.positionViewAtBeginning()
                }
                return;
            }
        }
        // If the date is greater than any item in the agenda, scroll to the bottom.
        agendaListView.positionViewAtEnd()
    }
}
