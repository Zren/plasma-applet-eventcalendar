import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Controls.Styles 1.0
import QtQuick.Dialogs 1.0
import QtQuick.Layouts 1.0
import org.kde.kirigami 2.0 as Kirigami

import ".."
import "../lib"
import "../lib/Requests.js" as Requests

ConfigPage {
	id: page
	showAppletVersion: true

	readonly property string localeTimeFormat: Qt.locale().timeFormat(Locale.ShortFormat)
	readonly property string localeDateFormat: Qt.locale().dateFormat(Locale.ShortFormat)
	readonly property string line1TimeFormat: clockTimeFormat.value || localeTimeFormat
	readonly property string line2TimeFormat: clockTimeFormat2.value || localeDateFormat

	property string timeFormat24hour: 'hh:mm'
	property string timeFormat12hour: 'h:mm AP'

	property bool showDebug: plasmoid.configuration.debugging
	property int indentWidth: 24 * Kirigami.Units.devicePixelRatio

	function setMouseWheelCommands(up, down) {
		plasmoid.configuration.clockMouseWheel == 'RunCommands'
		clockMousewheelGroupRunCommands.checked = true
		plasmoid.configuration.clockMouseWheelUp = up
		plasmoid.configuration.clockMouseWheelDown = down
	}



	//---

	LocaleInstaller {
		packageName: "org.kde.plasma.eventcalendar"
	}

	HeaderText {
		text: i18n("Widgets")
	}

	Label {
		Layout.maximumWidth: page.width
		wrapMode: Text.Wrap
		text: i18n("Show/Hide widgets above the calendar. Toggle Agenda/Calendar on their respective tabs.")
	}

	ConfigSection {
		ConfigCheckBox {
			configKey: 'widgetShowMeteogram'
			text: i18n("Meteogram")
		}
	}

	ConfigSection {
		ConfigCheckBox {
			id: widgetShowTimer
			configKey: 'widgetShowTimer'
			text: i18n("Timer")
		}
		RowLayout {
			Text { width: indentWidth } // indent
			ConfigSound {
				label: i18n("SFX:")
				sfxEnabledKey: 'timerSfxEnabled'
				sfxPathKey: 'timerSfxFilepath'
				sfxPathDefaultValue: '/usr/share/sounds/freedesktop/stereo/complete.oga'
				enabled: widgetShowTimer.checked
			}
		}
	}

	HeaderText {
		text: i18n("Clock")
	}
	ColumnLayout {
		HeaderText {
			text: i18n("Time Format")
			level: 3
		}

		LinkText {
			text: '<a href="https://doc.qt.io/qt-5/qml-qtqml-qt.html#formatDateTime-method">' + i18n("Time Format Documentation") + '</a>'
		}

		Label {
			Layout.maximumWidth: page.width
			wrapMode: Text.Wrap
			text: i18n("The default font for the Breeze theme is Noto Sans which is hard to read with small text. Try using the Sans Serif font if you find the text too small when adding a second line.")
		}

		Label {
			Layout.maximumWidth: page.width
			wrapMode: Text.Wrap
			text: i18n("You can also use %1 or %2 to style a section. Note the single quotes around the tags are used to bypass the time format.", "<b>\'&lt;b&gt;\'ddd\'&lt;\/b&gt;\'</b>", "<b>\'&lt;font color=\"#77aaadd\"&gt;\'ddd\'&lt;\/font&gt;\'</b>")
		}

		ConfigSection {
			ConfigFontFamily {
				id: clockFontFamily
				configKey: 'clockFontFamily'
				before: i18n("Font:")
			}

			RowLayout {
				Label {
					text: i18n("Fixed Clock Height: ")
				}
				
				ConfigSpinBox {
					configKey: 'clockMaxHeight'
					suffix: i18n("px")
					minimumValue: 0
				}

				Label {
					text: i18n(" (0px = scale to fit)")
				}
			}
		}

		ConfigSection {
			RowLayout {
				Layout.fillWidth: true
				CheckBox {
					checked: true
					text: i18n("Line 1:")
					onCheckedChanged: checked = true
				}
				ConfigString {
					id: clockTimeFormat
					configKey: 'clockTimeFormat1'
					placeholderText: localeTimeFormat
				}
				Label {
					text: Qt.formatDateTime(new Date(), line1TimeFormat)
				}
			}

			RowLayout {
				Layout.fillWidth: true
				Text { width: indentWidth } // indent
				Label {
					text: i18n("Preset:")
				}
				Button {
					text: Qt.formatDateTime(new Date(), timeFormat12hour)
					onClicked: clockTimeFormat.value = timeFormat12hour
				}
				Button {
					text: Qt.formatDateTime(new Date(), timeFormat24hour)
					onClicked: clockTimeFormat.value = timeFormat24hour
				}
				Button {
					property string dateFormat: Qt.locale().timeFormat(Locale.ShortFormat).replace('mm', 'mm:ss')
					text: Qt.formatDateTime(new Date(), dateFormat)
					onClicked: clockTimeFormat.value = dateFormat
				}
				Button {
					property string dateFormat: 'MMM d, ' + Qt.locale().timeFormat(Locale.ShortFormat)
					text: Qt.formatDateTime(new Date(), dateFormat)
					onClicked: clockTimeFormat.value = dateFormat
				}
			}

			RowLayout {
				Layout.fillWidth: true
				Text { width: indentWidth } // indent
				Label {
					text: i18n("Preset:")
					color: "transparent"
				}
				ColorTextButton {
					property string dateFormat: '\'<font color="#3daee9">\'MMM d\'</font>\' ' + Qt.locale().timeFormat(Locale.ShortFormat)
					label: Qt.formatDateTime(new Date(), dateFormat.replace())
					onClicked: clockTimeFormat.value = dateFormat
				}
				ColorTextButton {
					property string dateFormat: '\'<font color="#888">\'ddd<>d\'</font>\' h:mm\'<font color="#888">\'AP\'</font>\''
					label: Qt.formatDateTime(new Date(), dateFormat.replace())
					onClicked: clockTimeFormat.value = dateFormat
				}
			}

			RowLayout {
				Layout.fillWidth: true
				Text { width: indentWidth } // indent
				ConfigCheckBox {
					configKey: 'clockLineBold1'
					text: i18n("Bold")
				}
			}
		}

		ConfigSection {
			RowLayout {
				Layout.fillWidth: true
				ConfigCheckBox {
					configKey: 'clockShowLine2'
					text: i18n("Line 2:")
				}
				ConfigString {
					id: clockTimeFormat2
					configKey: 'clockTimeFormat2'
					placeholderText: localeDateFormat
				}
				Label {
					text: Qt.formatDateTime(new Date(), line2TimeFormat)
				}
			}

			RowLayout {
				Layout.fillWidth: true
				Text { width: indentWidth } // indent
				Label {
					text: i18n("Preset:")
				}
				Button {
					property string dateFormat: {
						// org.kde.plasma.digitalclock
						// remove "dddd" from the locale format string
						// /all/ locales in LongFormat have "dddd" either
						// at the beginning or at the end. so we just
						// remove it + the delimiter and space
						var format = Qt.locale().dateFormat(Locale.LongFormat)
						format = format.replace(/(^dddd.?\s)|(,?\sdddd$)/, "")
						return format
					}
					text: Qt.formatDate(new Date(), dateFormat)
					onClicked: clockTimeFormat2.value = dateFormat
				}
				Button {
					property string dateFormat: Qt.locale().dateFormat(Locale.ShortFormat)
					text: Qt.formatDate(new Date(), dateFormat)
					onClicked: clockTimeFormat2.value = dateFormat
				}
				Button {
					property string dateFormat: 'MMM d'
					text: Qt.formatDateTime(new Date(), dateFormat)
					onClicked: clockTimeFormat2.value = dateFormat
				}
				Button {
					text: "Sans Serif"
					onClicked: clockFontFamily.selectValue("Sans Serif")
				}
			}

			RowLayout {
				Layout.fillWidth: true
				Text { width: indentWidth } // indent
				ConfigCheckBox {
					configKey: 'clockLineBold2'
					text: i18n("Bold")
				}
			}

			RowLayout {
				Layout.fillWidth: true
				Text { width: indentWidth } // indent
				ConfigSlider {
					configKey: 'clockLine2HeightRatio'
					before: i18n("Height:")
					after: Math.floor(value * 100) + '%'
					minimumValue: 0.3
					maximumValue: 0.7
					stepSize: 0.01
				}
			}
		}



		HeaderText {
			text: i18n("Mouse Wheel")
			level: 3
		}
		ConfigSection {
			ExclusiveGroup { id: clockMousewheelGroup }

			RadioButton {
				id: clockMousewheelGroupRunCommands
				text: i18n("Run Commands")
				exclusiveGroup: clockMousewheelGroup
				checked: plasmoid.configuration.clockMouseWheel == 'RunCommands'
				onClicked: plasmoid.configuration.clockMouseWheel = 'RunCommands'
			}
			RowLayout {
				Layout.fillWidth: true
				Text { width: indentWidth } // indent
				Label {
					text: i18n("Scroll Up:")
				}
				ConfigString {
					id: clockMouseWheelUp
					configKey: 'clockMouseWheelUp'
				}
			}
			RowLayout {
				Layout.fillWidth: true
				Text { width: indentWidth } // indent
				Label {
					text: i18n("Scroll Down:")
				}
				ConfigString {
					id: clockMouseWheelDown
					configKey: 'clockMouseWheelDown'
				}
			}

			RadioButton {
				exclusiveGroup: clockMousewheelGroup
				checked: false
				text: i18n("Volume (No UI) (amixer)")
				property string upCommand:   'amixer -q sset Master 10%+'
				property string downCommand: 'amixer -q sset Master 10%-'
				onClicked: setMouseWheelCommands(upCommand, downCommand)
			}
			
			RadioButton {
				exclusiveGroup: clockMousewheelGroup
				checked: false
				text: i18n("Volume (UI) (qdbus)")
				property string upCommand:   'qdbus org.kde.kglobalaccel /component/kmix invokeShortcut "increase_volume"'
				property string downCommand: 'qdbus org.kde.kglobalaccel /component/kmix invokeShortcut "decrease_volume"'
				onClicked: setMouseWheelCommands(upCommand, downCommand)
			}
		}

	}

	HeaderText {
		text: i18n("Misc")
	}
	ConfigSection {
		ConfigCheckBox {
			configKey: 'showBackground'
			Layout.fillWidth: true
			text: i18n("Desktop Widget: Show background")
		}
	}

	HeaderText {
		text: i18n("Debugging")
	}
	ConfigSection {
		Label {
			text: i18n("Debugging will log sensitive information to:")
				+ '<br/><b>Kubuntu:</b> ~/.xsession-errors'
				+ '<br/><b>Arch/Manjaro:</b> journalctl -b0 _COMM=plasmashell'
			textFormat: Text.StyledText
		}
		ConfigCheckBox {
			configKey: 'debugging'
			text: i18n("Enable Debugging")
		}
	}
}
