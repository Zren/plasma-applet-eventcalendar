import QtQuick 2.0
import QtQuick.Controls 1.0
import QtQuick.Controls.Styles 1.0
import QtQuick.Dialogs 1.0
import QtQuick.Layouts 1.0
import org.kde.plasma.core 2.0 as PlasmaCore

import ".."
import "../lib"
import "../lib/Requests.js" as Requests

ConfigPage {
	id: page
	showAppletVersion: true

	property alias cfg_timer_sfx_filepath: timer_sfx_filepath.text
	property string cfg_clock_fontfamily: ""
	property alias cfg_clock_timeformat: clock_timeformat.text
	property alias cfg_clock_timeformat_2: clock_timeformat_2.text
	property string cfg_clock_mousewheel: "runcommand"
	property alias cfg_clock_mousewheel_up: clock_mousewheel_up.text
	property alias cfg_clock_mousewheel_down: clock_mousewheel_down.text

	readonly property string localeTimeFormat: Qt.locale().timeFormat(Locale.ShortFormat)
	readonly property string localeDateFormat: Qt.locale().dateFormat(Locale.ShortFormat)
	readonly property string line1TimeFormat: cfg_clock_timeformat || localeTimeFormat
	readonly property string line2TimeFormat: cfg_clock_timeformat_2 || localeDateFormat

	property string timeFormat24hour: 'hh:mm'
	property string timeFormat12hour: 'h:mm AP'

	property bool showDebug: plasmoid.configuration.debugging
	property int indentWidth: 24 * units.devicePixelRatio

	// populate
	onCfg_clock_fontfamilyChanged: {
		// org.kde.plasma.digitalclock
		// HACK by the time we populate our model and/or the ComboBox is finished the value is still undefined
		if (cfg_clock_fontfamily) {
			for (var i = 0, j = clock_fontfamilyComboBox.model.length; i < j; ++i) {
				if (clock_fontfamilyComboBox.model[i].value == cfg_clock_fontfamily) {
					clock_fontfamilyComboBox.currentIndex = i
					break
				}
			}
		}
	}

	function setMouseWheelCommands(up, down) {
		cfg_clock_mousewheel = 'run_commands'
		clock_mousewheelGroup_runcommands.checked = true
		cfg_clock_mousewheel_up = up
		cfg_clock_mousewheel_down = down
	}

	FileDialog {
		id: timer_sfx_filepathDialog
		title: i18n("Choose a sound effect")
		folder: '/usr/share/sounds'
		nameFilters: [ "Sound files (*.wav *.mp3 *.oga *.ogg)", "All files (*)" ]
		onAccepted: {
			console.log("You chose: " + fileUrls)
			cfg_timer_sfx_filepath = fileUrl
		}
		onRejected: {
			console.log("Canceled")
		}
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
			configKey: 'widget_show_meteogram'
			text: i18n("Meteogram")
		}
	}

	ConfigSection {
		ConfigCheckBox {
			configKey: 'widget_show_timer'
			text: i18n("Timer")
		}
		RowLayout {
			Text { width: indentWidth } // indent
			ConfigCheckBox {
				id: timerSfxEnabled
				configKey: 'timer_sfx_enabled'
				text: i18n("SFX:")
			}
			Button {
				text: i18n("Choose")
				onClicked: timer_sfx_filepathDialog.visible = true
				enabled: timerSfxEnabled.checked
			}
			TextField {
				id: timer_sfx_filepath
				Layout.fillWidth: true
				enabled: timerSfxEnabled.checked
				placeholderText: "/usr/share/sounds/freedesktop/stereo/complete.oga"
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
			RowLayout {
				Label {
					text: i18n("Font:")
				}
				ComboBox {
					// org.kde.plasma.digitalclock
					// Layout.fillWidth: true
					id: clock_fontfamilyComboBox
					textRole: "text" // doesn't autodeduce from model because we manually populate it

					Component.onCompleted: {
						// org.kde.plasma.digitalclock
						var arr = [] // use temp array to avoid constant binding stuff
						arr.push({text: i18n("Default"), value: ""})

						var fonts = Qt.fontFamilies()
						var foundIndex = 0
						for (var i = 0, j = fonts.length; i < j; ++i) {
							arr.push({text: fonts[i], value: fonts[i]})
						}
						model = arr
					}

					onCurrentIndexChanged: {
						var current = model[currentIndex]
						if (current) {
							page.cfg_clock_fontfamily = current.value
						}
					}
				}
			}

			RowLayout {
				Label {
					text: i18n("Fixed Clock Height: ")
				}
				
				ConfigSpinBox {
					configKey: 'clock_maxheight'
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
				TextField {
					Layout.fillWidth: true
					id: clock_timeformat
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
					onClicked: cfg_clock_timeformat = timeFormat12hour
				}
				Button {
					text: Qt.formatDateTime(new Date(), timeFormat24hour)
					onClicked: cfg_clock_timeformat = timeFormat24hour
				}
				Button {
					property string dateFormat: Qt.locale().timeFormat(Locale.ShortFormat).replace('mm', 'mm:ss')
					text: Qt.formatDateTime(new Date(), dateFormat)
					onClicked: cfg_clock_timeformat = dateFormat
				}
				Button {
					property string dateFormat: 'MMM d, ' + Qt.locale().timeFormat(Locale.ShortFormat)
					text: Qt.formatDateTime(new Date(), dateFormat)
					onClicked: cfg_clock_timeformat = dateFormat
				}
			}

			RowLayout {
				Layout.fillWidth: true
				Text { width: indentWidth } // indent
				Label {
					text: i18n("Preset:")
					color: "transparent"
				}
				Button {
					property string dateFormat: '\'<font color="#3daee9">\'MMM d\'</font>\' ' + Qt.locale().timeFormat(Locale.ShortFormat)
					text: Qt.formatDateTime(new Date(), dateFormat.replace())
					onClicked: cfg_clock_timeformat = dateFormat
					style: ButtonStyle {}
				}
				Button {
					property string dateFormat: '\'<font color="#888">\'ddd<>d\'</font>\' h:mm\'<font color="#888">\'AP\'</font>\''
					text: Qt.formatDateTime(new Date(), dateFormat.replace())
					onClicked: cfg_clock_timeformat = dateFormat
					style: ButtonStyle {}
				}
			}

			RowLayout {
				Layout.fillWidth: true
				Text { width: indentWidth } // indent
				ConfigCheckBox {
					configKey: 'clock_line_1_bold'
					text: i18n("Bold")
				}
			}
		}

		ConfigSection {
			RowLayout {
				Layout.fillWidth: true
				ConfigCheckBox {
					configKey: 'clock_line_2'
					text: i18n("Line 2:")
				}
				TextField {
					Layout.fillWidth: true
					id: clock_timeformat_2
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
					onClicked: cfg_clock_timeformat_2 = dateFormat
				}
				Button {
					property string dateFormat: Qt.locale().dateFormat(Locale.ShortFormat)
					text: Qt.formatDate(new Date(), dateFormat)
					onClicked: cfg_clock_timeformat_2 = dateFormat
				}
				Button {
					property string dateFormat: 'MMM d'
					text: Qt.formatDateTime(new Date(), dateFormat)
					onClicked: cfg_clock_timeformat_2 = dateFormat
				}
				Button {
					text: "Sans Serif"
					onClicked: cfg_clock_fontfamily = "Sans Serif"
				}
			}

			RowLayout {
				Layout.fillWidth: true
				Text { width: indentWidth } // indent
				ConfigCheckBox {
					configKey: 'clock_line_2_bold'
					text: i18n("Bold")
				}
			}

			RowLayout {
				Layout.fillWidth: true
				Text { width: indentWidth } // indent
				ConfigSlider {
					configKey: 'clock_line_2_height_ratio'
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
			ExclusiveGroup { id: clock_mousewheelGroup }

			RadioButton {
				id: clock_mousewheelGroup_runcommands
				exclusiveGroup: clock_mousewheelGroup
				checked: cfg_clock_mousewheel == 'run_commands'
				text: i18n("Run Commands")
				onClicked: {
					cfg_clock_mousewheel = 'run_commands'
				}
			}
			RowLayout {
				Layout.fillWidth: true
				Text { width: indentWidth } // indent
				Label {
					text: i18n("Scroll Up:")
				}
				TextField {
					Layout.fillWidth: true
					id: clock_mousewheel_up
				}
			}
			RowLayout {
				Layout.fillWidth: true
				Text { width: indentWidth } // indent
				Label {
					text: i18n("Scroll Down:")
				}
				TextField {
					Layout.fillWidth: true
					id: clock_mousewheel_down
				}
			}

			RadioButton {
				exclusiveGroup: clock_mousewheelGroup
				checked: false
				text: i18n("Volume (No UI) (amixer)")
				onClicked: {
					setMouseWheelCommands('amixer -q sset Master 10%+', 'amixer -q sset Master 10%-')
				}
			}
			
			RadioButton {
				exclusiveGroup: clock_mousewheelGroup
				checked: false
				text: i18n("Volume (UI) (qdbus)")
				property string upCommand:   'qdbus org.kde.kglobalaccel /component/kmix invokeShortcut "increase_volume"'
				property string downCommand: 'qdbus org.kde.kglobalaccel /component/kmix invokeShortcut "decrease_volume"'
				onClicked: {
					setMouseWheelCommands(upCommand, downCommand)
				}
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
		ConfigCheckBox {
			configKey: 'debugging'
			text: i18n("Enable Debugging\nThis will log sensitive information to ~/.xsession-errors")
		}
	}
}
