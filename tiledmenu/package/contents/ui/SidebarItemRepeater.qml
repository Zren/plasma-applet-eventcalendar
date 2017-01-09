import QtQuick 2.0

Repeater {
	id: repeater
	delegate: SidebarItem {
		expanded: true
		labelVisible: true
		iconName: model.iconName
		text: model.name
		onClicked: {
			// console.log(repeater, repeater.parent)
			repeater.parent.parent.open = false // SidebarContextMenu { Column { Repeater{} } }
			repeater.model.triggerIndex(index)
		}
		
	}
}
