import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents
import org.kde.plasma.components 3.0 as PlasmaComponents3

import "LocaleFuncs.js" as LocaleFuncs
import "Shared.js" as Shared

LinkRect {
	id: agendaTaskItem
	readonly property int taskItemIndex: index
	width: undefined
	Layout.fillWidth: true
	implicitHeight: contents.implicitHeight
	property bool eventItemInProgress: false
	function checkIfInProgress() {
		if (model.startDateTime && timeModel.currentTime && model.endDateTime) {
			eventItemInProgress = model.startDateTime <= timeModel.currentTime && timeModel.currentTime <= model.endDateTime
		} else {
			eventItemInProgress = false
		}
		// console.log('checkIfInProgress()', model.start, timeModel.currentTime, model.end)
	}
	Connections {
		target: timeModel
		onLoaded: agendaTaskItem.checkIfInProgress()
		onMinuteChanged: agendaTaskItem.checkIfInProgress()
	}
	Component.onCompleted: {
		agendaTaskItem.checkIfInProgress()

		//--- Debugging
		// editTaskForm.active = eventItemInProgress && !model.startDateTime
	}

	property alias isEditing: editTaskForm.active
	enabled: !isEditing

	readonly property string eventTimestamp: LocaleFuncs.formatEventDuration(model, {
		relativeDate: agendaItemDate,
		clock24h: appletConfig.clock24h,
	})

	RowLayout {
		id: contents
		anchors.left: parent.left
		anchors.right: parent.right
		spacing: 4 * units.devicePixelRatio

		PlasmaComponents3.CheckBox {
			Layout.alignment: Qt.AlignTop
			checked: model.isCompleted
			enabled: false
		}

		ColumnLayout {
			id: taskColumn
			Layout.alignment: Qt.AlignTop
			Layout.fillWidth: true
			spacing: 0

			PlasmaComponents3.Label {
				id: taskTitle
				text: model.title
				color: eventItemInProgress ? inProgressColor : PlasmaCore.ColorScope.textColor
				font.pointSize: -1
				font.pixelSize: appletConfig.agendaFontSize
				font.weight: eventItemInProgress ? inProgressFontWeight : Font.Normal
				visible: !editTaskForm.visible
				Layout.fillWidth: true

				// The Following doesn't seem to be applicable anymore (left comment just in case).
				// Wrapping causes reflow, which causes scroll to selection to miss the selected date
				// since it reflows after updateUI/scrollToDate is done.
				wrapMode: Text.Wrap
			}

			PlasmaComponents3.Label {
				id: taskDue
				readonly property bool showProperty: !!model.due
				visible: showProperty && !editTaskForm.visible
				text: eventTimestamp
				color: eventItemInProgress ? inProgressColor : PlasmaCore.ColorScope.textColor
				opacity: eventItemInProgress ? 1 : 0.75
				font.pointSize: -1
				font.pixelSize: appletConfig.agendaFontSize
				font.weight: eventItemInProgress ? inProgressFontWeight : Font.Normal
			}

			Item {
				id: taskNoteSpacing
				visible: taskNotes.visible
				implicitHeight: 4 * units.devicePixelRatio
			}

			PlasmaComponents3.Label {
				id: taskNotes
				readonly property bool showProperty: plasmoid.configuration.agendaShowEventDescription && text
				visible: showProperty && !editTaskForm.visible
				text: Shared.renderText(model.notes)
				color: PlasmaCore.ColorScope.textColor
				opacity: 0.75
				font.pointSize: -1
				font.pixelSize: appletConfig.agendaFontSize
				Layout.fillWidth: true
				wrapMode: Text.Wrap // See warning at taskTitle.wrapMode

				linkColor: PlasmaCore.ColorScope.highlightColor
				onLinkActivated: Qt.openUrlExternally(link)
				MouseArea {
					anchors.fill: parent
					acceptedButtons: Qt.NoButton // we don't want to eat clicks on the Text
					cursorShape: parent.hoveredLink ? Qt.PointingHandCursor : Qt.ArrowCursor
				}
			}

			Item {
				id: taskEditorSpacing
				visible: editTaskForm.visible
				implicitHeight: 4 * units.devicePixelRatio
			}

			EditEventForm {
				id: editTaskForm
				// active: true
			}

		} // taskColumn

		PlasmaComponents.ToolButton {
			Layout.alignment: Qt.AlignTop
			iconName: "zoom-in" // Breeze icon looks like "open link iocn"
			onClicked: Qt.openUrlExternally(model.htmlLink)
		}
	}
	
	onLeftClicked: {
		var task = tasks.get(index)
		logger.logJSON("task", task)
		// var tasklist = eventModel.getTasklist(task.tasklistId)
		// logger.logJSON("tasklist", tasklist)

		// eventModel.toggleCompleted(event.tasklistId, task.id)
	}

	onLoadContextMenu: {
		var menuItem
		var task = tasks.get(index)

		menuItem = contextMenu.newMenuItem()
		menuItem.text = i18n("Edit")
		menuItem.icon = "edit-rename"
		// menuItem.enabled = task.canEdit
		menuItem.clicked.connect(function() {
			editTaskForm.active = !editTaskForm.active
			agendaScrollView.positionViewAtEvent(agendaItemIndex, eventItemIndex)
		})
		contextMenu.addMenuItem(menuItem)

		var deleteMenuItem = contextMenu.newSubMenu()
		deleteMenuItem.text = i18n("Delete Event")
		deleteMenuItem.icon = "delete"
		menuItem = contextMenu.newMenuItem(deleteMenuItem)
		menuItem.text = i18n("Confirm Deletion")
		menuItem.icon = "delete"
		// menuItem.enabled = task.canEdit
		menuItem.clicked.connect(function() {
			logger.debug('eventModel.deleteTask', task.tasklistId, task.id)
			// eventModel.deleteTask(task.tasklistId, task.id)
		})
		// deleteMenuItem.enabled = task.canEdit
		deleteMenuItem.subMenu.addMenuItem(menuItem)
		contextMenu.addMenuItem(deleteMenuItem)

		menuItem = contextMenu.newMenuItem()
		menuItem.text = i18n("Edit in browser")
		menuItem.icon = "internet-web-browser"
		menuItem.enabled = !!task.htmlLink
		menuItem.clicked.connect(function() {
			Qt.openUrlExternally(task.htmlLink)
		})
		contextMenu.addMenuItem(menuItem)
	}
}
