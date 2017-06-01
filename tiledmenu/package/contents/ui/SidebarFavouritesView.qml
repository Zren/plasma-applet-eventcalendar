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
			var xdgFolder = isLocalizedFolder()
			if (xdgFolder === 'Documents') {
				executable.exec('xdg-open $(xdg-user-dir DOCUMENTS)')
			} else if (xdgFolder === 'Downloads') {
				executable.exec('xdg-open $(xdg-user-dir DOWNLOAD)')
			} else if (xdgFolder === 'Music') {
				executable.exec('xdg-open $(xdg-user-dir MUSIC)')
			} else if (xdgFolder === 'Pictures') {
				executable.exec('xdg-open $(xdg-user-dir PICTURES)')
			} else if (xdgFolder === 'Videos') {
				executable.exec('xdg-open $(xdg-user-dir VIDEOS)')
			} else {
				repeater.model.triggerIndex(index)
			}
		}
		visible: index >= minVisibleIndex

		// These files are localize, so open them via commandline
		// since Qt 5.7 doesn't expose the localized paths anywhere.
		function isLocalizedFolder() {
			var s = model.url.toString()
			if (startsWith(s, 'file:///home/')) {
				s = s.substring('file:///home/'.length, s.length)
				// console.log(model.url, s)

				var trimIndex = s.indexOf('/')
				if (trimIndex == -1) { // file:///home/username
					s = ''
				} else {
					s = s.substring(trimIndex, s.length)
				}
				// console.log(model.url, s)

				if (s === '/Documents') {
					return 'Documents'
				} else if (s === '/Downloads') {
					return 'Downloads'
				} else if (s === '/Music') {
					return 'Music'
				} else if (s === '/Pictures') {
					return 'Pictures'
				} else if (s === '/Videos') {
					return 'Videos'
				}
			}
			return ''
		}

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
