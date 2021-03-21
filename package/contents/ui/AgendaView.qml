import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore

import "Shared.js" as Shared
import "LocaleFuncs.js" as LocaleFuncs

Item {
	id: agendaView

	readonly property int scrollbarWidth: width - agendaScrollView.contentWidth

	property color inProgressColor: appletConfig.agendaInProgressColor
	property int inProgressFontWeight: Font.Bold

	property color isOverdueColor: PlasmaCore.ColorScope.negativeTextColor
	property int isOverdueFontWeight: Font.Bold

	signal newEventFormOpened(var agendaItem, var calendarSelector)
	signal submitNewEventForm(string calendarId, var date, string text)

	Connections {
		target: eventModel
		onEventCreated: {
			notificationManager.notify({
				appName: i18n("Event Calendar"),
				appIcon: "resource-calendar-insert",
				// expireTimeout: 10000,
				summary: data.summary,
				body: LocaleFuncs.formatEventDuration(data, {
					relativeDate: timeModel.currentTime,
					clock24h: appletConfig.clock24h,
				})
			})
		}
		onEventDeleted: {
			logger.logJSON('AgendaView.onEventDeleted', data)
			notificationManager.notify({
				appName: i18n("Event Calendar"),
				appIcon: "user-trash-symbolic",
				// expireTimeout: 10000,
				summary: data.summary,
				body: LocaleFuncs.formatEventDuration(data, {
					relativeDate: timeModel.currentTime,
					clock24h: appletConfig.clock24h,
				})
			})
		}
	}

	ScrollView {
		id: agendaScrollView
		anchors.fill: parent
		// clip: true
		readonly property int contentWidth: contentItem ? contentItem.width : width
		readonly property int contentHeight: contentItem ? contentItem.height : 0 // Warning: Binding loop
		readonly property int viewportWidth: viewport ? viewport.width : width
		readonly property int viewportHeight: viewport ? viewport.height : height
		readonly property int scrollY: flickableItem ? flickableItem.contentY : 0

		// onScrollYChanged: console.log('scrollY', scrollY)

		ColumnLayout {
			id: agendaColumn
			width: agendaScrollView.viewportWidth
			spacing: appletConfig.agendaDaySpacing

			Repeater {
				id: agendaRepeater

				property bool populated: false
				// onPopulatedChanged: console.log(Date.now(), 'agendaRepeater.populated', populated)
				model: root.agendaModel
				delegate: AgendaListItem {
					// visible: agendaRepeater.populated
					width: parent.width
					// onHeightChanged: {
					// 	if (scrollToIndexTimer.running) {
					// 		scrollToIndexTimer.updatePosition()
					// 	}
					// }
					
					// Component.onCompleted: console.log(Date.now(), 'AgendaListItem.onCompleted', index)
					// Component.onDestruction: console.log(Date.now(), 'AgendaListItem.onDestruction', index)
				}

				onItemAdded: {
					// console.log(Date.now(), 'agendaRepeater.itemAdded', index)
					if (index === root.agendaModel.count-1) {
						populated = true
					}
				}
				onItemRemoved: {
					// console.log(Date.now(), 'agendaRepeater.onItemRemoved', index)
					populated = false
				}
			}
		}

		function getCurrentAgendaItem() {
			if (agendaRepeater.count === 0 || scrollY < 0) {
				return null
			} else {
				var offsetY = 0
				for (var i = 0; i < agendaRepeater.count; i++) {
					var agendaListItem = agendaRepeater.itemAt(i)
					offsetY += agendaListItem ? agendaListItem.height : 0
					// console.log('\t', i, agendaListItem, agendaListItem.height)
					if (i != agendaRepeater.count-1) {
						offsetY += agendaColumn.spacing
					}

					if (offsetY >= scrollY) {
						return agendaListItem
					}
				}
				return null
			}
		}

		function getItemOffsetY(index) {
			// console.log('getItemOffsetY', index)
			if (index <= 0) {
				return 0
			} else if (index < agendaRepeater.count) {
				// console.log('\t', index < agendaRepeater.count)
				var offsetY = 0
				for (var i = 0; i < Math.min(index, agendaRepeater.count); i++) {
					var agendaListItem = agendaRepeater.itemAt(i)
					offsetY += agendaListItem ? agendaListItem.height : 0
					// console.log('\t', i, agendaListItem, agendaListItem.height)
					if (i != agendaRepeater.count-1) {
						offsetY += agendaColumn.spacing
					}
				}
				return offsetY
			} else { // index >= agendaRepeater.count
				return agendaScrollView.contentHeight
			}
		}

		function scrollToY(offsetY) {
			flickableItem.contentY = Math.min(offsetY, contentHeight-viewportHeight)
		}

		function positionViewAtBeginning() {
			scrollToY(0)
		}

		function positionViewAtIndex(i) {
			var offsetY = getItemOffsetY(i)
			scrollToY(offsetY)
		}

		function positionViewAtEvent(agendaItemIndex, eventIndex) {
			var offsetY = getItemOffsetY(agendaItemIndex)
			var agendaListItem = agendaRepeater.itemAt(agendaItemIndex)
			offsetY += agendaListItem.getEventOffset(eventIndex)
			scrollToY(offsetY)
		}

		function positionViewAtTask(agendaItemIndex, taskIndex) {
			var offsetY = getItemOffsetY(agendaItemIndex)
			var agendaListItem = agendaRepeater.itemAt(agendaItemIndex)
			var eventIndex = agendaListItem.agendaItemEvents.count + taskIndex
			offsetY += agendaListItem.getEventOffset(eventIndex)
			scrollToY(offsetY)
		}

		function positionViewAtEnd() {
			scrollToY(contentHeight)
		}
	}

	// TODO: properly detect when all events have completed loading
	Timer {
		id: scrollToIndexTimer
		property int itemIndex: -1
		interval: 400 // Give events time to populate
		onTriggered: updatePosition()
		function scrollTo(i) {
			itemIndex = i
			restart()
		}
		function updatePosition() {
			// console.log('updatePosition', itemIndex, Date.now())
			agendaScrollView.positionViewAtIndex(itemIndex)
		}
	}

	function scrollToTop() {
		agendaScrollView.positionViewAtBeginning()
	}

	function scrollToDate(date) {
		for (var i = 0; i < root.agendaModel.count; i++) {
			var agendaItem = root.agendaModel.get(i)
			if (Shared.isSameDate(date, agendaItem.date)) {
				agendaScrollView.positionViewAtIndex(i)
				scrollToIndexTimer.scrollTo(i)
				return
			} else if (Shared.isDateEarlier(date, agendaItem.date)) {
				// If the date is smaller than the current agendaItem.date, scroll to the previous agendaItem.
				if (i > 0) {
					agendaScrollView.positionViewAtIndex(i-1)
					scrollToIndexTimer.scrollTo(i-1)
				} else {
					agendaScrollView.positionViewAtBeginning()
				}
				return
			}
		}
		// If the date is greater than any item in the agenda, scroll to the bottom.
		agendaScrollView.positionViewAtEnd()
	}

	// [Note] This function is untested!
	function scrollToEvent(date, eventId) {
		for (var i = 0; i < agendaRepeater.model.count; i++) {
			var agendaItem = agendaRepeater.model.get(i)
			if (Shared.isSameDate(date, agendaItem.date)) {
				var agendaListItem = agendaRepeater.itemAt(i)
				var eventIndex = agendaListItem.indexOfEvent(eventId)
				if (eventIndex >= 0) {
					scrollToIndexTimer.scrollTo(i)
				}
				return
			} else if (Shared.isDateEarlier(date, agendaItem.date)) {
				// If the date is smaller than the current agendaItem.date, then we've iterated past the target date.
				return
			}
		}
		// The date was greater than any item in the agenda.
	}
}
