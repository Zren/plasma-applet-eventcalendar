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
	property bool cityListLoaded: false

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
		onTriggered: filteredCityListModel.filterRegExp = cityNameInput.text
	}

	onVisibleChanged: {
		if (!cityListLoaded && !loadingCityList) {
			loadCityList()
		}
	}


	ColumnLayout {
		anchors.fill: parent
		LinkText { 
			text: i18n("Fetched from <a href=\"http://openweathermap.org/help/city_list.txt\">http://openweathermap.org/help/city_list.txt</a>")
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


	function loadCityList() {
		chooseCityDialog.loadingCityList = true
		var url = 'http://openweathermap.org/help/city_list.txt';
		Requests.request(url, function(err, data) {
		// Requests.getFile('OpenWeatherMapCityList.tsv', function(err, data) {
			// console.log(data);
			// tab seperated values
			var lines = data.split('\n');
			lines.shift(); //Header: "id	nm	lat	lon	countryCode"

			for (var i = 0; i < lines.length; i++) {
				var row = lines[i].split('\t');
				if (row.length >= 2) {
					var city = {
						id: row[0],
						name: row[1] + ', ' + row[4],
					};
					cityListModel.append(city);
				}
			}
			
			// link after populating so that each append() doesn't attempt to rebuild the UI.
			filteredCityListModel.sourceModel = cityListModel
			
			chooseCityDialog.cityListLoaded = true
			chooseCityDialog.loadingCityList = false
		})
	}
}
