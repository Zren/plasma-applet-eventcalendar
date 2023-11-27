import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Controls 2.0 as QQC2
import QtQuick.Layouts 1.1
import org.kde.kirigami 2.0 as Kirigami

import ".."
import "../lib"
import "../lib/Requests.js" as Requests

ConfigPage {
	id: page

	function alphaColor(c, a) {
		return Qt.rgba(c.r, c.g, c.b, a)
	}
	readonly property color readablePositiveTextColor: Qt.tint(Kirigami.Theme.textColor, alphaColor(Kirigami.Theme.positiveTextColor, 0.5))
	readonly property color readableNegativeTextColor: Qt.tint(Kirigami.Theme.textColor, alphaColor(Kirigami.Theme.negativeTextColor, 0.5))

	function sortByKey(key, a, b){
		if (typeof a[key] === "string") {
			return a[key].toLowerCase().localeCompare(b[key].toLowerCase())
		} else if (typeof a[key] === "number") {
			return a[key] - b[key]
		} else {
			return 0
		}
	}
	function sortArr(arr, predicate) {
		if (typeof predicate === "string") { // predicate is a key
			predicate = sortByKey.bind(null, predicate)
		}
		return arr.concat().sort(predicate)
	}

	GoogleLoginManager {
		id: googleLoginManager

		onCalendarListChanged: {
			calendarsModel.clear()
			var sortedList = sortArr(calendarList, "summary")
			for (var i = 0; i < sortedList.length; i++) {
				var item = sortedList[i]
				// console.log(JSON.stringify(item))
				var isPrimary = item.primary === true
				var isShown = calendarIdList.indexOf(item.id) >= 0 || (isPrimary && calendarIdList.indexOf('primary') >= 0)
				calendarsModel.append({
					calendarId: item.id, 
					name: item.summary,
					description: item.description,
					backgroundColor: item.backgroundColor,
					foregroundColor: item.foregroundColor,
					show: isShown,
					isReadOnly: item.accessRole == "reader",
				})
				// console.log(item.summary, isShown, item.id)
			}
			calendarsModel.calendarsShownChanged()
		}

		onTasklistListChanged: {
			tasklistsModel.clear()
			var sortedList = sortArr(tasklistList, "title")
			for (var i = 0; i < sortedList.length; i++) {
				var item = sortedList[i]
				// console.log(JSON.stringify(item))
				var isShown = tasklistIdList.indexOf(item.id) >= 0
				tasklistsModel.append({
					tasklistId: item.id, 
					name: item.title,
					description: '',
					backgroundColor: Kirigami.Theme.highlightColor.toString(),
					foregroundColor: Kirigami.Theme.highlightedTextColor.toString(),
					show: isShown,
					isReadOnly: false,
				})
				// console.log(item.summary, isShown, item.id)
			}
			tasklistsModel.tasklistsShownChanged()
		}

		onError: messageWidget.err(err)
	}


	HeaderText {
		text: i18n("Login")
	}
	MessageWidget {
		id: messageWidget
	}
	ColumnLayout {
		visible: googleLoginManager.isLoggedIn
		Label {
			Layout.fillWidth: true
			text: i18n("Currently Synched.")
			color: readablePositiveTextColor
			wrapMode: Text.Wrap
		}
		Button {
			text: i18n("Logout")
			onClicked: {
				googleLoginManager.logout()
				calendarsModel.clear()
			}
		}
		MessageWidget {
			visible: googleLoginManager.needsRelog
			text: i18n("Widget has been updated. Please logout and login to Google Calendar again.")
		}
	}
	ColumnLayout {
		visible: !googleLoginManager.isLoggedIn
		Label {
			Layout.fillWidth: true
			text: i18n("To sync with Google Calendar click the button to first authorize your account.")
			color: readableNegativeTextColor
			wrapMode: Text.Wrap
		}
		RowLayout {
			Button {
				text: i18n("Authorize")
				onClicked: {
					googleLoginManager.fetchAccessToken()
				}
			}
		}
		
	}

	RowLayout {
		Layout.fillWidth: true
		visible: googleLoginManager.isLoggedIn

		HeaderText {
			text: i18n("Calendars")
		}

		Button {
			iconName: "view-refresh"
			text: i18n("Refresh")
			onClicked: googleLoginManager.updateCalendarList()
		}
	}
	ColumnLayout {
		spacing: Kirigami.Units.smallSpacing * 2
		Layout.fillWidth: true
		visible: googleLoginManager.isLoggedIn

		ListModel {
			id: calendarsModel

			signal calendarsShownChanged()

			onCalendarsShownChanged: {
				var calendarIdList = []
				for (var i = 0; i < calendarsModel.count; i++) {
					var item = calendarsModel.get(i)
					if (item.show) {
						calendarIdList.push(item.calendarId)
					}
				}
				googleLoginManager.calendarIdList = calendarIdList
			}
		}

		ColumnLayout {
			Layout.fillWidth: true

			Repeater {
				model: calendarsModel
				delegate: CheckBox {
					text: model.name
					checked: model.show
					style: CheckBoxStyle {
						label: RowLayout {
							Rectangle {
								Layout.fillHeight: true
								Layout.preferredWidth: height
								color: model.backgroundColor
							}
							Label {
								id: labelText
								text: control.text
							}
							LockIcon {
								Layout.fillHeight: true
								Layout.preferredWidth: height
								visible: model.isReadOnly
							}
						}
						
					}

					onClicked: {
						calendarsModel.setProperty(index, 'show', checked)
						calendarsModel.calendarsShownChanged()
					}
				}
			}
		}
	}

	RowLayout {
		Layout.fillWidth: true
		visible: googleLoginManager.isLoggedIn

		HeaderText {
			text: i18n("Tasks")

			Image {
				source: plasmoid.file("", "icons/google_tasks_96px.png")
				smooth: true
				anchors.leftMargin: parent.contentWidth + Kirigami.Units.smallSpacing
				anchors.left: parent.left
				anchors.verticalCenter: parent.verticalCenter
				width: Kirigami.Units.iconSizes.smallMedium
				height: Kirigami.Units.iconSizes.smallMedium
			}
		}

		Button {
			iconName: "view-refresh"
			text: i18n("Refresh")
			onClicked: googleLoginManager.updateTasklistList()
		}
	}
	ColumnLayout {
		spacing: Kirigami.Units.smallSpacing * 2
		Layout.fillWidth: true
		visible: googleLoginManager.isLoggedIn

		ListModel {
			id: tasklistsModel

			signal tasklistsShownChanged()

			onTasklistsShownChanged: {
				var tasklistIdList = []
				for (var i = 0; i < tasklistsModel.count; i++) {
					var item = tasklistsModel.get(i)
					if (item.show) {
						tasklistIdList.push(item.tasklistId)
					}
				}
				googleLoginManager.tasklistIdList = tasklistIdList
			}
		}

		ColumnLayout {
			Layout.fillWidth: true

			Repeater {
				model: tasklistsModel
				delegate: CheckBox {
					text: model.name
					checked: model.show
					style: CheckBoxStyle {
						label: RowLayout {
							Rectangle {
								Layout.fillHeight: true
								Layout.preferredWidth: height
								color: model.backgroundColor
							}
							Label {
								id: labelText
								text: control.text
							}
							LockIcon {
								Layout.fillHeight: true
								Layout.preferredWidth: height
								visible: model.isReadOnly
							}
						}
						
					}

					onClicked: {
						tasklistsModel.setProperty(index, 'show', checked)
						tasklistsModel.tasklistsShownChanged()
					}
				}
			}
		}
	}

	HeaderText {
		text: i18n("Options")
		visible: googleLoginManager.isLoggedIn
	}

	ColumnLayout {
		Layout.fillWidth: true
		visible: googleLoginManager.isLoggedIn

		ConfigRadioButtonGroup {
			id: googleEventClickAction
			label: i18n("Event Click:")
			configKey: 'googleEventClickAction'
			model: [
				{ value: 'WebEventView', text: i18n("Open Web Event View") },
				{ value: 'WebMonthView', text: i18n("Open Web Month View") },
			]
		}

		ConfigCheckBox {
			configKey: 'googleHideGoalsDesc'
			text: i18n("Hide \"This event was added from Goals in Google Calendar\" description")
		}
	}

	Component.onCompleted: {
		if (googleLoginManager.isLoggedIn) {
			googleLoginManager.calendarListChanged()
			googleLoginManager.tasklistListChanged()
		}
	}
}
