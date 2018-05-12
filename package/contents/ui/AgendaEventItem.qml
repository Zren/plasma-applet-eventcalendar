import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.extras 2.0 as PlasmaExtras

import "LocaleFuncs.js" as LocaleFuncs

LinkRect {
    id: agendaEventItem
    width: undefined
    Layout.fillWidth: true
    Layout.preferredHeight: eventColumn.height
    // height: eventColumn.height
    property bool eventItemInProgress: false
    function checkIfInProgress() {
        eventItemInProgress = start && timeModel.currentTime && end ? start.dateTime <= timeModel.currentTime && timeModel.currentTime <= end.dateTime : false
        // console.log('checkIfInProgress()', start, timeModel.currentTime, end)
    }
    Connections {
        target: timeModel
        onLoaded: agendaEventItem.checkIfInProgress()
        onMinuteChanged: agendaEventItem.checkIfInProgress()
    }
    Component.onCompleted: agendaEventItem.checkIfInProgress()

    property bool isEditing: editSummaryForm.active || editDateTimeForm.active
    enabled: !isEditing

    RowLayout {
        width: parent.width

        Rectangle {
            Layout.preferredWidth: appletConfig.eventIndicatorWidth
            Layout.preferredHeight: eventColumn.height
            color: model.backgroundColor || theme.textColor
        }

        ColumnLayout {
            id: eventColumn
            Layout.fillWidth: true
            spacing: 0

            PlasmaComponents.Label {
                id: eventSummary
                text: summary
                color: eventItemInProgress ? inProgressColor : PlasmaCore.ColorScope.textColor
                font.pointSize: -1
                font.pixelSize: appletConfig.agendaFontSize
                font.weight: eventItemInProgress ? inProgressFontWeight : Font.Normal
                height: paintedHeight
                visible: !editSummaryForm.active
                Layout.fillWidth: true

                // The Following doesn't seem to be applicable anymore (left comment just in case).
                // Wrapping causes reflow, which causes scroll to selection to miss the selected date
                // since it reflows after updateUI/scrollToDate is done.
                wrapMode: Text.Wrap
            }

            Loader {
                id: editSummaryForm
                active: false
                visible: active
                Layout.fillWidth: true
                sourceComponent: Component {
                    PlasmaComponents.TextField {
                        id: editEventText
                        placeholderText: i18n("Event Summary")
                        text: summary
                        onAccepted: {
                            console.log('editEventText.onAccepted', text)
                            var event = events.get(index)
                            console.log(event)
                            console.log(JSON.stringify(event))
                            eventModel.setEventSummary(event.calendarId, event.id, text)
                        }
                        Component.onCompleted: {
                            focus = true
                        }

                        Keys.onEscapePressed: editSummaryForm.active = false
                    }
                }
            }

            PlasmaComponents.Label {
                id: eventDateTime
                text: {
                    LocaleFuncs.formatEventDuration(model, {
                        relativeDate: agendaItemDate,
                        clock24h: appletConfig.clock24h,
                    })
                }
                color: eventItemInProgress ? inProgressColor : PlasmaCore.ColorScope.textColor
                opacity: eventItemInProgress ? 1 : 0.75
                font.pointSize: -1
                font.pixelSize: appletConfig.agendaFontSize
                font.weight: eventItemInProgress ? inProgressFontWeight : Font.Normal
                height: paintedHeight
                visible: !editDateTimeForm.active
            }

            Loader {
                id: editDateTimeForm
                active: false
                visible: active
                Layout.fillWidth: true
                sourceComponent: Component {
                    RowLayout {
                        property alias isAllDayEvent: editAllDay.checked

                        ColumnLayout {
                            Layout.fillWidth: true
                            RowLayout {
                                DateSelector {
                                    id: editStartDate
                                    Layout.fillWidth: true
                                    dateTime: model.start.dateTime
                                    onDateTimeChanged: {
                                        var t1 = model.start.dateTime.valueOf()
                                        var t2 = dateTime.valueOf()
                                        console.log('dt1', model.start.dateTime)
                                        console.log('dt2', dateTime)
                                        var dateDelta = Math.floor((t2 - t1) / (1000*60*60*24))
                                        console.log('dateDelta', dateDelta)

                                        var shiftedEndDate = new Date(model.end.dateTime)
                                        shiftedEndDate.setDate(shiftedEndDate.getDate() + dateDelta)
                                        editEndDate.dateTime = shiftedEndDate
                                    }
                                }

                                PlasmaComponents.TextField {
                                    id: editStartTime
                                    Layout.fillWidth: true
                                    enabled: !isAllDayEvent
                                    placeholderText: '9:00am'
                                    text: Qt.formatTime(model.start.dateTime)
                                }
                            }
                            PlasmaComponents.Label {
                                text: i18n("to")
                                Layout.fillWidth: true
                                horizontalAlignment: Text.AlignHCenter
                            }
                            RowLayout {
                                DateSelector {
                                    id: editEndDate
                                    Layout.fillWidth: true
                                    dateTime: model.end.dateTime
                                }

                                PlasmaComponents.TextField {
                                    id: editEndTime
                                    Layout.fillWidth: true
                                    enabled: !isAllDayEvent
                                    placeholderText: '10:00am'
                                    text: Qt.formatTime(model.end.dateTime)
                                }
                            }
                        }

                        ColumnLayout {
                            Layout.alignment: Qt.AlignTop
                            PlasmaComponents.CheckBox {
                                id: editAllDay
                                text: i18n("All Day")
                                Layout.minimumWidth: 0
                                checked: !!model.start.date
                            }
                            PlasmaComponents.Button {
                                text: i18n("Save")
                                Layout.minimumWidth: 0
                                onClicked: {
                                    // ...
                                    editDateTimeForm.active = false
                                }
                            }
                            PlasmaComponents.Button {
                                text: i18n("Discard")
                                Layout.minimumWidth: 0
                                onClicked: editDateTimeForm.active = false
                            }
                        }
                    } // RowLayout
                } // Component
            } // Loader
        } // eventColumn
    }
    
    onLeftClicked: {
        // console.log('agendaItem.event.leftClicked', start.date, mouse)
        if (false) {
            var event = events.get(index)
            console.log("event", JSON.stringify(event, null, '\t'))
            var calendar = eventModel.getCalendar(event.calendarId)
            console.log("calendar", JSON.stringify(calendar, null, '\t'))
            upcomingEvents.sendEventStartingNotification(model)
        } else {
            // cfg_agenda_event_clicked == "browser_viewevent"
            Qt.openUrlExternally(htmlLink)
        }
    }

    onLoadContextMenu: {
        var menuItem;
        var event = events.get(index)

        menuItem = contextMenu.newMenuItem();
        menuItem.text = i18n("Edit description");
        menuItem.icon = "edit-rename"
        menuItem.enabled = event.canEdit
        menuItem.clicked.connect(function() {
            editSummaryForm.active = !editSummaryForm.active
        });
        contextMenu.addMenuItem(menuItem);

        menuItem = contextMenu.newMenuItem();
        menuItem.text = i18n("Edit date/time");
        menuItem.enabled = event.canEdit
        menuItem.clicked.connect(function() {
            editDateTimeForm.active = !editDateTimeForm.active
        });
        // contextMenu.addMenuItem(menuItem);

        var deleteMenuItem = contextMenu.newSubMenu();
        deleteMenuItem.text = i18n("Delete Event");
        deleteMenuItem.icon = "delete"
        menuItem = contextMenu.newMenuItem(deleteMenuItem);
        menuItem.text = i18n("Confirm Deletion");
        menuItem.icon = "delete"
        menuItem.enabled = event.canEdit
        menuItem.clicked.connect(function() {
            logger.debug('eventModel.deleteEvent', model.calendarId, model.id)
            eventModel.deleteEvent(model.calendarId, model.id)
        });
        deleteMenuItem.enabled = event.canEdit
        deleteMenuItem.subMenu.addMenuItem(menuItem);
        contextMenu.addMenuItem(deleteMenuItem);

        menuItem = contextMenu.newMenuItem();
        menuItem.text = i18n("Edit in browser");
        menuItem.icon = "internet-web-browser"
        menuItem.enabled = !!event.htmlLink
        menuItem.clicked.connect(function() {
            Qt.openUrlExternally(model.htmlLink)
        });
        contextMenu.addMenuItem(menuItem);
    }
}
