import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore

import ".."
import "../lib"
import "../lib/Requests.js" as Requests

ConfigPage {
	id: page

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

	GoogleCalendarSession {
		id: session

		onCalendarListChanged: {
			calendarsModel.clear()
			var sortedList = sortArr(calendarList, "summary")
			for (var i = 0; i < sortedList.length; i++) {
				var item = sortedList[i]
				// console.log(JSON.stringify(item))
				var isShowned = calendarIdList.indexOf(item.id) >= 0
				calendarsModel.append({
					calendarId: item.id, 
					name: item.summary,
					description: item.description,
					backgroundColor: item.backgroundColor,
					foregroundColor: item.foregroundColor,
					show: isShowned,
					isReadOnly: item.accessRole == "reader",
				})
				// console.log(item.summary, isShowned, item.id)
			}
			calendarsModel.calendarsShownChanged()
		}

		onErrorFetchingUserCode: messageWidget.err(err)
	}


	HeaderText {
		text: i18n("Login")
	}
	MessageWidget {
		id: messageWidget
	}
	ColumnLayout {
		visible: session.accessToken
		Label {
			Layout.fillWidth: true
			text: i18n("Currently Synched.")
			color: "#3c763d"
			wrapMode: Text.Wrap
		}
		Button {
			text: i18n("Logout")
			onClicked: {
				session.reset()
				calendarsModel.clear()
			}
		}
	}
	ColumnLayout {
		visible: !session.accessToken
		Label {
			Layout.fillWidth: true
			text: i18n("To sync with Google Calendar")
			color: "#8a6d3b"
			wrapMode: Text.Wrap
		}
		LinkText {
			Layout.fillWidth: true
			text: i18n("Visit <a href=\"%1\">%2</a> (opens in your web browser). After you login and give permission to acess your calendar, it will give you a code to paste below.", session.authorizationCodeUrl, 'https://accounts.google.com/...')
			color: "#8a6d3b"
			wrapMode: Text.Wrap
		}
		RowLayout {
			TextField {
				id: authorizationCodeInput
				Layout.fillWidth: true

				placeholderText: i18n("Enter code here (Eg: %1)", '1/2B3C4defghijklmnopqrst-uvwxyz123456789ab-cdeFGHIJKlmnio')
				text: ""
			}
			Button {
				text: i18n("Submit")
				onClicked: {
					if (authorizationCodeInput.text) {
						session.fetchAccessToken({
							authorizationCode: authorizationCodeInput.text,
						})
					} else {
						messageWidget.err(i18n("Invalid Google Authorization Code"))
					}
				}
			}
		}
		
	}

	RowLayout {
		Layout.fillWidth: true

		HeaderText {
			text: i18n("Calendars")
		}

		Button {
			iconName: "view-refresh"
			text: i18n("Refresh")
			onClicked: session.updateCalendarList()
		}
	}
	ColumnLayout {
		spacing: units.smallSpacing * 2
		Layout.fillWidth: true

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
				session.calendarIdList = calendarIdList
			}
		}

		ColumnLayout {
			Layout.fillWidth: true

			Repeater {
				model: calendarsModel
				delegate: CheckBox {
					text: name
					checked: show
					style: CheckBoxStyle {
						label: RowLayout {
							Rectangle {
								Layout.fillHeight: true
								Layout.preferredWidth: height
								color: backgroundColor
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

	Component.onCompleted: {
		if (!session.accessToken) {
			// session.generateUserCodeAndPoll()
		} else {
			session.calendarListChanged()
		}
	}
}
