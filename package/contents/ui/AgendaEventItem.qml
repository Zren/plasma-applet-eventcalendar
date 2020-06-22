import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

import "LocaleFuncs.js" as LocaleFuncs

LinkRect {
	id: agendaEventItem
	readonly property int eventItemIndex: index
	width: undefined
	Layout.fillWidth: true
	Layout.preferredHeight: eventColumn.height
	// height: eventColumn.height
	property bool eventItemInProgress: false
	function checkIfInProgress() {
		eventItemInProgress = model.startDateTime && timeModel.currentTime && model.endDateTime ? model.startDateTime <= timeModel.currentTime && timeModel.currentTime <= model.endDateTime : false
		// console.log('checkIfInProgress()', model.start, timeModel.currentTime, model.end)
	}
	Connections {
		target: timeModel
		onLoaded: agendaEventItem.checkIfInProgress()
		onMinuteChanged: agendaEventItem.checkIfInProgress()
	}
	Component.onCompleted: {
		agendaEventItem.checkIfInProgress()

		//--- Debugging
		// editEventForm.active = eventItemInProgress && !model.startDateTime
	}

	property alias isEditing: editEventForm.active
	enabled: !isEditing

	readonly property string eventTimestamp: LocaleFuncs.formatEventDuration(model, {
		relativeDate: agendaItemDate,
		clock24h: appletConfig.clock24h,
	})
	readonly property bool isAllDay: eventTimestamp == i18n("All Day") // TODO: Remove string comparison.
	readonly property bool isCondensed: plasmoid.configuration.agendaCondensedAllDayEvent && isAllDay

	RowLayout {
		width: parent.width
		spacing: 4 * units.devicePixelRatio

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
				text: {
					if (isCondensed && model.location) {
						return model.summary + " | " + model.location
					} else {
						return model.summary
					}
				}
				color: eventItemInProgress ? inProgressColor : PlasmaCore.ColorScope.textColor
				font.pointSize: -1
				font.pixelSize: appletConfig.agendaFontSize
				font.weight: eventItemInProgress ? inProgressFontWeight : Font.Normal
				height: paintedHeight
				visible: !editEventForm.visible
				Layout.fillWidth: true

				// The Following doesn't seem to be applicable anymore (left comment just in case).
				// Wrapping causes reflow, which causes scroll to selection to miss the selected date
				// since it reflows after updateUI/scrollToDate is done.
				wrapMode: Text.Wrap
			}

			PlasmaComponents.Label {
				id: eventDateTime
				text: {
					if (model.location) {
						return eventTimestamp + " | " + model.location
					} else {
						return eventTimestamp
					}
				}
				color: eventItemInProgress ? inProgressColor : PlasmaCore.ColorScope.textColor
				opacity: eventItemInProgress ? 1 : 0.75
				font.pointSize: -1
				font.pixelSize: appletConfig.agendaFontSize
				font.weight: eventItemInProgress ? inProgressFontWeight : Font.Normal
				height: paintedHeight
				visible: !editEventForm.visible && !isCondensed
			}

			Item {
				id: eventDescriptionSpacing
				visible: eventDescription.visible
				Layout.preferredHeight: 4 * units.devicePixelRatio
			}

			PlasmaComponents.Label {
				id: eventDescription
				readonly property bool showProperty: plasmoid.configuration.agendaShowEventDescription && text
				visible: showProperty && !editEventForm.visible
				text: renderText(model.description)
				color: PlasmaCore.ColorScope.textColor
				opacity: 0.75
				font.pointSize: -1
				font.pixelSize: appletConfig.agendaFontSize
				height: paintedHeight
				Layout.fillWidth: true
				wrapMode: Text.Wrap // See warning at eventSummary.wrapMode
				
				linkColor: PlasmaCore.ColorScope.highlightColor
				onLinkActivated: Qt.openUrlExternally(link)
				MouseArea {
					anchors.fill: parent
					acceptedButtons: Qt.NoButton // we don't want to eat clicks on the Text
					cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
				}

				function renderText(text) {
					// console.log('renderText')
					if (typeof text === 'undefined') {
						return ''
					}
					var out = text
					// text && console.log('renderText', text)
					
					// Render links
					// Google doesn't auto-convert links to anchor tags when you paste a link in the description.
					// However, we should treat it as a link. This simple regex replacement works when we're not
					// dealing with HTML. So if we see an HTML anchor tag, skip it and assume the link has been
					// formatted.
					if (out.indexOf('<a href') == -1) {
						var rUrl = /(http|https):\/\/[\w-]+(\.[\w-]+)+([\w.,@?^=%&amp;:\/~+#-]*[\w@?^=%&amp;\/~+#-])?/gi
						out = out.replace(rUrl, function(m) {
							// Google replaces ampersands with HTML the entity in the url text.
							var encodedUrl = m.replace(/\&/g, '&amp;')

							// console.log('        m', m)
							// console.log('      enc', encodedUrl)

							// Add extra space at the end to prevent styling entire text as a link when ending with a link.
							return '<a href="' + m + '">' + encodedUrl + '</a>' + '&nbsp;'
						})
					}
					// text && console.log('    Links', out)

					// Render new lines
					// out = out.replace(/\n/g, '<br>')
					// text && console.log('    Newlines', out)

					// Remove leading new line, as Google sometimes adds them.
					out = out.replace(/^(\<br\>)+/, '')
					// text && console.log('    LeadingBR', out)

					return out
				}
			}

			Item {
				id: eventEditorSpacing
				visible: editEventForm.visible
				Layout.preferredHeight: 4 * units.devicePixelRatio
			}

			EditEventForm {
				id: editEventForm
				// active: true
			}

			Item {
				id: eventEditorSpacingBelow
				visible: editEventForm.visible
				Layout.preferredHeight: 4 * units.devicePixelRatio
			}

			PlasmaComponents.ToolButton {
				id: eventHangoutLink
				visible: plasmoid.configuration.agendaShowEventHangoutLink && !!model.hangoutLink
				text: i18n("Hangout")
				iconSource: plasmoid.file("", "icons/hangouts.svg")
				onClicked: Qt.openUrlExternally(model.hangoutLink)
			}

		} // eventColumn
	}
	
	onLeftClicked: {
		// console.log('agendaItem.event.leftClicked', model.startDateTime, mouse)
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
		var menuItem
		var event = events.get(index)

		menuItem = contextMenu.newMenuItem()
		menuItem.text = i18n("Edit")
		menuItem.icon = "edit-rename"
		menuItem.enabled = event.canEdit
		menuItem.clicked.connect(function() {
			editEventForm.active = !editEventForm.active
			agendaScrollView.positionViewAtEvent(agendaItemIndex, eventItemIndex)
		})
		contextMenu.addMenuItem(menuItem)

		var deleteMenuItem = contextMenu.newSubMenu()
		deleteMenuItem.text = i18n("Delete Event")
		deleteMenuItem.icon = "delete"
		menuItem = contextMenu.newMenuItem(deleteMenuItem)
		menuItem.text = i18n("Confirm Deletion")
		menuItem.icon = "delete"
		menuItem.enabled = event.canEdit
		menuItem.clicked.connect(function() {
			logger.debug('eventModel.deleteEvent', model.calendarId, model.id)
			eventModel.deleteEvent(model.calendarId, model.id)
		})
		deleteMenuItem.enabled = event.canEdit
		deleteMenuItem.subMenu.addMenuItem(menuItem)
		contextMenu.addMenuItem(deleteMenuItem)

		menuItem = contextMenu.newMenuItem()
		menuItem.text = i18n("Edit in browser")
		menuItem.icon = "internet-web-browser"
		menuItem.enabled = !!event.htmlLink
		menuItem.clicked.connect(function() {
			Qt.openUrlExternally(model.htmlLink)
		})
		contextMenu.addMenuItem(menuItem)
	}
}
