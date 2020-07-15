import QtQuick 2.2
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 3.0 as PlasmaComponents3

// Technique based on plasma-applet-weather-widget
// https://github.com/kotelnik/plasma-applet-weather-widget/blob/320ed5661475f176116e1785476dc51710494b86/package/contents/code/icons.js
Item {
	width: 16
	height: 16
	property string source: ""
	property alias color: iconText.color
	property bool showOutline: true
	
	// FontLoader {
	// 	source: "../fonts/weathericons-regular-webfont.ttf"
	// }

	PlasmaComponents3.Label {
		id: iconText
		text: ''
		color: PlasmaCore.ColorScope.textColor
		style: showOutline ? Text.Outline : Text.Normal
		styleColor: PlasmaCore.ColorScope.backgroundColor

		font.family: "weathericons"
		font.pointSize: -1
		font.pixelSize: parent.height
		anchors.centerIn: parent
	}

	// https://erikflowers.github.io/weather-icons/
	function getIconCode(name) {
		var codeByName = {
			'question': '?',
			'weather-clear': '\uf00d',
			'weather-clear-night': '\uf02e', // wi-day-sunny
			'weather-clouds': '\uf041', // wi-cloud
			'weather-clouds-night': '\uf041', // wi-cloud
			'weather-few-clouds': '\uf002', // wi-day-cloudy
			'weather-few-clouds-night': '\uf086', // wi-night-alt-cloudy
			'weather-fog': '\uf014', // wi-fog
			'weather-freezing-rain': '\uf0b5', // wi-sleet
			'weather-hail': '\uf015', // wi-hail
			'weather-overcast': '\uf013', // wi-cloudy
			'weather-showers': '\uf019', // wi-rain
			'weather-showers-night': '\uf019', // wi-rain
			'weather-showers-scattered': '\uf009', // wi-day-showers
			'weather-showers-scattered-night': '\uf029', // wi-night-alt-showers
			'weather-snow': '\uf01b', // wi-snow
			'weather-snow-rain': '\uf006', // wi-day-rain-mix
			'weather-snow-rain-night': '\uf034', // wi-night-rain-mix
			'weather-snow-scattered-day': '\uf00a', // wi-day-snow
			'weather-snow-scattered-night': '\uf038', // wi-night-snow
			'weather-storm': '\uf01e', // wi-thunderstorm
			'weather-storm-night': '\uf025', // wi-night-alt-lightning
			'wi-dust': '\uf063', // wi-dust
			'wi-sandstorm': '\uf082', // wi-sandstorm
			'wi-smoke': '\uf062', // wi-smoke
			'wi-tornado': '\uf056', // wi-tornado
			'wi-windy': '\uf021', // wi-windy
		}
		return codeByName[name]
	}

	function setIcon() {
		if (!source) {
			return
		}
		
		var code = getIconCode(source);
		iconText.text = code ? code : ''
		if (!code) {
			console.log('missing fontIcon', source)
		}
	}

	onSourceChanged: {
		setIcon()
	}

	Component.onCompleted: {
		setIcon()
	}
}
