import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Layouts 1.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

PlasmaComponents.TextField {
	id: dateSelector
	placeholderText: '31/12/2017' // Note that US/Canada is 12/31/2017
	function formatDate(dt) {
		return dt.toLocaleDateString(Locale.ShortFormat)
	}

	text: dateSelector.formatDate(dateSelector.dateTime)
	onTextChanged: {
		console.log('onTextChanged', text, '(focus = ', focus, ')')
		if (focus) {
			var l = Qt.locale()
			// var dateFormat = l.dateFormat(Locale.ShortFormat)
			var dt = Date.fromLocaleDateString(l, text, Locale.ShortFormat)
			var t = dt.valueOf()
			if (isNaN(t)) {
				console.log('parsed invalid date', dt)
			} else {
				// uk (ukrainian) formats to "31.10.17" but is parsed as 31 Oct 1917
				// So if the year is before 1970, just add 100 years.
				// We'll also just check <1969 in case there's a timezone bug.
				// Hopefully this code isn't still in use in 50 years.
				if (dt.getFullYear() < 1969) {
					console.log('Parsed year to before 1970 (we probably wanted 20xx)', dt)
					dt.setYear(dt.getFullYear() + 100)
				}

				console.log('new date', dt)
				dateSelector.dateTime = dt
			}

			
			// var t = Date.parse(text)
			// if (isNaN(t)) {
			// } else {
			// 	dateSelector.dateTime = new Date(t)
			// }
			// console.log('new date', new Date(text), dateSelector.dateTime)
		}
	}

	property var dateTime: new Date()
	onDateTimeChanged: {
		console.log('onDateTimeChanged', dateTime, '(focus = ', focus, ')')
		if (!focus) {
			
		}
	}

	onEditingFinished: {
		dateSelector.text = Qt.binding(function(){ return dateSelector.formatDate(dateSelector.dateTime) })
	}

	property alias dialogContents: dialogLoader.item
	property alias dialogLocation: toolTipArea.location

	PlasmaCore.ToolTipArea {
		id: toolTipArea
		anchors.fill: parent
		location: dateSelector.dialogLocation
		interactive: true
		
		mainItem: Loader {
			id: dialogLoader
			sourceComponent: Component {
				FocusScope {
					id: focusScope
					width: 300 * units.devicePixelRatio
					height: 300 * units.devicePixelRatio

					MonthView {
						id: dateSelectorMonthView
						anchors.fill: parent
						today: popup.today
						currentDate: dateSelector.dateTime
						displayedDate: dateSelector.dateTime

						showTooltips: false
						showTodaysDate: false

						onDateSelected: {
							console.log('onDateSelected', currentDate)
							dateSelector.dateTime = currentDate
						}
					}
				}
			}
		}
	}

	
	
}
