import QtQuick 2.0
import QtQuick.Controls 1.1
import QtQuick.Controls.Styles 1.1
import QtQuick.Layouts 1.1
import QtQuick.Window 2.1
import org.kde.plasma.core 2.0 as PlasmaCore
import org.kde.plasma.components 2.0 as PlasmaComponents

ScrollView {
	id: appsView

	KickerListView {
		id: appsListView
		
		section.property: 'name'
		section.criteria: ViewSection.FirstCharacter

		model: appsModel.allAppsModel // Should be populated by the time this is created

		showItemUrl: false
		largeFirstItem: false
	}

}