import QtQuick 2.1
import QtQuick.Dialogs 1.2
import QtQuick.Layouts 1.2
import QtQuick.Controls 1.4
import org.kde.plasma.core 2.0 as PlasmaCore

import "../lib/Requests.js" as Requests
import ".."
import "../../code/WeatherCanada.js" as WeatherCanada

Dialog {
	id: chooseCityDialog
	title: i18n("Select city")

	width: 500
	height: 600
	property bool loadingCityList: false
	property bool cityListLoaded: false

	ListModel { id: emptyListModel }
	ListModel { id: cityListModel }
	PlasmaCore.SortFilterModel {
		id: filteredCityListModel
		// sourceModel: cityListModel // Link after populating cityListModel so the UI doesn't freeze.
		sourceModel: emptyListModel
		filterRole: 'name'
		sortRole: 'name'
		sortCaseSensitivity: Qt.CaseInsensitive 
	}

	property string selectedCityId: ''
	Connections {
		target: tableView.selection
		
		onSelectionChanged: {
			tableView.selection.forEach(function(row) {
				var city = filteredCityListModel.get(row)
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
		if (visible && !cityListLoaded && !loadingCityList) {
			loadProvinceCityList()
		}
	}


	ColumnLayout {
		anchors.fill: parent
		LinkText {
			text: i18n("Fetched from <a href=\"%1\">%1</a>", "https://weather.gc.ca/canada_e.html")
		}

		Item {
			height: 21
			Layout.fillWidth: true
			TabView {
				id: provinceTabView
				width: parent.width
				frameVisible: false
				Repeater {
					id: provinceRepeater
					model: ['AB', 'BC', 'MB', 'NB', 'NL', 'NS', 'NT', 'NU', 'ON', 'PE', 'QC', 'SK', 'YT']
					Tab { title: modelData }
				}
				onCurrentIndexChanged: loadProvinceCityList()
			}
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
					text: '<a href="https://weather.gc.ca/city/pages/' + styleData.value + '_metric_e.html">' + i18n("Open Link") + '</a>'
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


	function loadCityList(provinceUrl) {
		chooseCityDialog.loadingCityList = true
		filteredCityListModel.sourceModel = emptyListModel
		cityListModel.clear()

		Requests.request(provinceUrl, function(err, data) {
			// console.log(data)
			var cityList = WeatherCanada.parseProvincePage(data)
			for (var i = 0; i < cityList.length; i++) {
				cityListModel.append(cityList[i])
			}
			
			// link after populating so that each append() doesn't attempt to rebuild the UI.
			filteredCityListModel.sourceModel = cityListModel
			
			chooseCityDialog.cityListLoaded = true
			chooseCityDialog.loadingCityList = false
		})
	}

	property alias provinceIdList: provinceRepeater.model
	function loadProvinceCityList() {
		var provinceId = provinceIdList[0]
		if (provinceTabView.currentIndex >= 0) {
			provinceId = provinceIdList[provinceTabView.currentIndex]
		}
		
		var provinceUrl = 'https://weather.gc.ca/forecast/canada/index_e.html?id=' + provinceId
		loadCityList(provinceUrl)
	}
}
