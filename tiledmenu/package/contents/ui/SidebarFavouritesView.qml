import QtQuick 2.0

Repeater {
	id: repeater
	property int maxHeight: 1000000
	property int numAvailable: maxHeight / config.flatButtonSize
	property int minVisibleIndex: count - numAvailable // Hide items with an index smaller than this

	delegate: SidebarItem {
		icon: symbolicIconName || model.iconName || model.decoration
		text: model.name || model.display
		sidebarMenu: repeater.parent.parent // SidebarContextMenu { Column { Repeater{} } }
		onClicked: {
			repeater.parent.parent.open = false // SidebarContextMenu { Column { Repeater{} } }
			repeater.model.triggerIndex(index)
		}
		visible: index >= minVisibleIndex


		function startsWith(s, sub) {
			return s.indexOf(sub) === 0
		}
		function endsWith(s, sub) {
			return s.indexOf(sub) === s.length - sub.length
		}
		property string symbolicIconName: {
			if (model.url) {
				var s = model.url.toString()
				if (endsWith(s, '.desktop')) {
					if (endsWith(s, '/org.kde.dolphin.desktop')) {
						return 'folder-open-symbolic'
					} else if (endsWith(s, '/systemsettings.desktop')) {
						return 'configure'
					}
				} else if (startsWith(s, 'file:///home/')) {
					s = s.substring('file:///home/'.length, s.length)
					// console.log(model.url, s)

					var trimIndex = s.indexOf('/')
					if (trimIndex == -1) { // file:///home/username
						s = ''
					} else {
						s = s.substring(trimIndex, s.length)
					}
					// console.log(model.url, s)

					if (s === '') { // Home Directory
						return 'user-home-symbolic'
					} else if (s === '/Documents') {
						return 'folder-documents-symbolic'
					} else if (s === '/Downloads') {
						return 'folder-download-symbolic'
					} else if (s === '/Music') {
						return 'folder-music-symbolic'
					} else if (s === '/Pictures') {
						return 'folder-pictures-symbolic'
					} else if (s === '/Videos') {
						return 'folder-videos-symbolic'
					}
				}
			}
			return ""
		}
	}
}
