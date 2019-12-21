import QtQuick 2.0
import QtQuick.Window 2.2

import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents3

import QtQuick.Templates 2.1 as T
import QtQuick.Controls 2.1 as Controls
import QtGraphicalEffects 1.0 // DropShadow

// Based on:
// https://github.com/KDE/plasma-framework/blob/master/src/declarativeimports/plasmacomponents3/ComboBox.qml
// https://doc.qt.io/archives/qt-5.11/qml-qtquick-controls2-combobox.html
// https://github.com/qt/qtquickcontrols2/blob/dev/src/quicktemplates2/qquickcombobox.cpp

PlasmaComponents3.TextField {
	id: timeSelector
	readonly property Item control: timeSelector

	property int defaultMinimumWidth: 80 * units.devicePixelRatio
	readonly property int implicitContentWidth: contentWidth + leftPadding + rightPadding
	implicitWidth: Math.max(defaultMinimumWidth, implicitContentWidth)

	property var dateTime: new Date()
	property var timeFormat: Locale.ShortFormat

	signal dateTimeShifted(date oldDateTime, int deltaDateTime, date newDateTime)
	signal entryActivated(int index)

	function setDateTime(newDateTime) {
		var oldDateTime = new Date(dateTime)
		var deltaDateTime = newDateTime.valueOf() - oldDateTime.valueOf()
		dateTimeShifted(oldDateTime, deltaDateTime, newDateTime)
	}
	function updateText() {
		text = Qt.binding(function(){
			return timeSelector.dateTime.toLocaleTimeString(Qt.locale(), timeSelector.timeFormat)
		})
	}

	property string valueRole: "dt"
	property string textRole: "label"
	property var model: {
		var dt = dateTime
		var midnight = new Date(dt.getFullYear(), dt.getMonth(), dt.getDate(), 0, 0, 0)
		var interval = 30 // minutes
		var intervalMillis = interval*60*1000
		var numEntries = Math.ceil(24*60 / interval) // 30min intervals = 48 entries
		var l = []
		for (var i = 0; i < numEntries; i++) {
			var deltaT = i * intervalMillis
			var entryDateTime = new Date(midnight.valueOf() + deltaT)
			var entry = {
				dt: entryDateTime,
				label: entryDateTime.toLocaleTimeString(Qt.locale(), timeSelector.timeFormat)
			}
			l.push(entry)
		}
		return l
	}

	onPressed: {
		popup.open()
		highlightDateTime(dateTime)
	}

	onEntryActivated: {
		if (0 <= index && index < model.length) {
			var entry = model[index]
			setDateTime(entry[control.valueRole])
		}
	}

	onTextEdited: {
		var dt = Date.fromLocaleTimeString(Qt.locale(), text, timeSelector.timeFormat)
		// console.log('onTextEdited', text, dt)
		if (!isNaN(dt)) {
			setDateTime(dt)
			highlightDateTime(dt)
		}
	}

	function highlightDateTime(dt) {
		for (var i = 0; i < model.length; i++) {
			var entry = model[i]
			var eDT = entry[valueRole]
			if (dt.getHours() == eDT.getHours() && dt.getMinutes() == eDT.getMinutes()) {
				listView.currentIndex = i
				listView.positionViewAtIndex(i, ListView.Contain)
				return
			}
		}
		listView.currentIndex = -1 // Unselect
	}

	onEditingFinished: updateText()
	Component.onCompleted: updateText()

	property Component delegate: PlasmaComponents3.ItemDelegate {
		width: control.popup.width
		text: control.textRole ? (Array.isArray(control.model) ? modelData[control.textRole] : model[control.textRole]) : modelData
		property bool separatorVisible: false
		highlighted: listView.currentIndex === index

		onClicked: {
			listView.currentIndex = index
			control.entryActivated(listView.currentIndex)
			popup.close()
		}
	}

	property T.Popup popup: T.Popup {
		x: control.mirrored ? control.width - width : 0
		y: control.height
		property int minWidth: 120 * units.devicePixelRatio
		property int maxHeight: 150 * units.devicePixelRatio
		width: Math.max(control.width, minWidth)
		implicitHeight: Math.min(contentItem.implicitHeight, maxHeight)
		topMargin: 6 * units.devicePixelRatio
		bottomMargin: 6 * units.devicePixelRatio

		contentItem: ListView {
			id: listView
			clip: true
			implicitHeight: contentHeight
			highlightRangeMode: ListView.ApplyRange
			highlightMoveDuration: 0
			// HACK: When the ComboBox is not inside a top-level Window, it's Popup does not inherit
			// the LayoutMirroring options. This is a workaround to fix this by enforcing
			// the LayoutMirroring options properly.
			// QTBUG: https://bugreports.qt.io/browse/QTBUG-66446
			LayoutMirroring.enabled: Qt.application.layoutDirection === Qt.RightToLeft
			LayoutMirroring.childrenInherit: true
			T.ScrollBar.vertical: Controls.ScrollBar { }

			model: control.popup.visible ? control.model : null
			delegate: control.delegate
		}
		background: Rectangle {
			anchors {
				fill: parent
				margins: -1
			}
			radius: 2
			color: theme.viewBackgroundColor
			border.color: Qt.rgba(theme.textColor.r, theme.textColor.g, theme.textColor.b, 0.3)
			layer.enabled: true

			layer.effect: DropShadow {
				transparentBorder: true
				radius: 4
				samples: 8
				horizontalOffset: 2
				verticalOffset: 2
				color: Qt.rgba(0, 0, 0, 0.3)
			}
		}
	} // Popup
}
