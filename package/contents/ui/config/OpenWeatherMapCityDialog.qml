import QtQuick 2.1
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.2
import QtQuick.Controls 1.4
import org.kde.plasma.core 2.0 as PlasmaCore

import "../lib/Requests.js" as Requests
import ".."

Dialog {
	id: chooseCityDialog
	title: i18n("Select city")

	width: 500
	height: 600
	property bool loadingCityList: false

	Logger {
		id: logger
		showDebug: plasmoid.configuration.debugging
	}

	ListModel { id: cityListModel }
	PlasmaCore.SortFilterModel {
		id: filteredCityListModel
		// sourceModel: cityListModel // Link after populating cityListModel so the UI doesn't freeze.
		filterRole: 'name'
		sortRole: 'name'
		sortCaseSensitivity: Qt.CaseInsensitive 
	}

	property string selectedCityId: ''
	Connections {
		target: tableView.selection
		
		onSelectionChanged: {
			tableView.selection.forEach(function(row) {
				var city = filteredCityListModel.get(row);
				chooseCityDialog.selectedCityId = city.id
				// console.log('selectedCityId', city.id, city.name)
			})
		}
	}
	Connections {
		target: filteredCityListModel
		
		onFilterRegExpChanged: {
			tableView.selection.clear()
			chooseCityDialog.selectedCityId = ''
		}
	}

	Timer {
		id: debouceApplyFilter
		interval: 1000
		onTriggered: chooseCityDialog.applyCityListSearch()
	}


	ColumnLayout {
		anchors.fill: parent
		LinkText { 
			text: i18n("Fetched from <a href=\"https://openweathermap.org/find\">https://openweathermap.org/find</a>")
		}
		TextField {
			id: cityNameInput
			Layout.fillWidth: true
			text: ''
			placeholderText: i18n("Search")
			onTextChanged: debouceApplyFilter.restart()
		}
		TableView {
			id: tableView
			Layout.fillWidth: true
			Layout.fillHeight: true
			Layout.minimumHeight: 200
			model: filteredCityListModel

			TableViewColumn {
				width: 240
				role: 'name'
				title: i18n("Name")
			}
			TableViewColumn {
				width: 100
				role: 'id'
				title: i18n("Id")
			}
			TableViewColumn {
				width: 100
				role: 'id'
				title: i18n("City Webpage")
				delegate: LinkText {
					text: '<a href="http://openweathermap.org/city/' + styleData.value + '">' + i18n("Open Link") + '</a>'
					linkColor: styleData.selected ? theme.textColor : theme.highlightColor
				}
			}

			BusyIndicator {
				anchors.centerIn: parent
				running: visible
				visible: chooseCityDialog.loadingCityList
			}
		}
	}

	function clearCityList() {
		// clear list so that each append() doesn't rebuild the UI
		filteredCityListModel.sourceModel = null
		cityListModel.clear()
	}

	function parseCityList(data) {
		for (var i = 0; i < data.list.length; i++) {
			var item = data.list[i]
			var city = {
				id: item.id,
				name: item.name + ', ' + item.sys.country,
			}
			cityListModel.append(city)
		}
	}

	function applyCityListSearch() {
		searchCityList(cityNameInput.text)
	}

	function searchCityList(q) {
		console.log('searchCityList', q)
		clearCityList()
		if (q) {
			chooseCityDialog.loadingCityList = true
			fetchCityList({
				app_id: plasmoid.configuration.weather_app_id,
				q: q,
			}, function(err, data, xhr) {
				if (err) return console.log('searchCityList.err', err, xhr && xhr.status, data)
				logger.log('searchCityList.response')
				logger.debugJSON('searchCityList.response', data)

				parseCityList(data)

				// link after populating so that each append() doesn't attempt to rebuild the UI.
				filteredCityListModel.sourceModel = cityListModel
				
				chooseCityDialog.loadingCityList = false
			})
		}
	}

	function fetchCityList(args, callback) {
		if (!args.app_id) return callback('OpenWeatherMap AppId not set');
		
		var url = 'http://api.openweathermap.org/data/2.5/'
		url += 'find?q=' + encodeURIComponent(args.q)
		url += '&type=like'
		url += '&sort=population'
		url += '&cnt=30'
		url += '&appid=' + args.app_id
		Requests.getJSON(url, callback);
	}
}
