import QtQuick 2.0

QtObject {
	property var tile: null
	readonly property string favoriteId: tile && tile.url || ''
	readonly property var app: favoriteId ? appsModel.tileGridModel.getApp(favoriteId) : null
	readonly property string appLabel: app ? app.display : ""
	readonly property string appUrl: app ? app.url : ""
	readonly property var appIcon: app ? app.decoration : null
	readonly property string labelText: tile && tile.label || appLabel || appUrl || ""
	readonly property var iconSource: tile && tile.icon || appIcon
	readonly property bool iconFill: tile && typeof tile.iconFill !== "undefined" ? tile.iconFill : false
	readonly property bool showIcon: tile && typeof tile.showIcon !== "undefined" ? tile.showIcon : true
	readonly property bool showLabel: tile && typeof tile.showLabel !== "undefined" ? tile.showLabel : true
	readonly property color backgroundColor: tile && typeof tile.backgroundColor !== "undefined" ? tile.backgroundColor : config.defaultTileColor

	readonly property int tileW: tile && typeof tile.w !== "undefined" ? tile.w : 2
	readonly property int tileH: tile && typeof tile.h !== "undefined" ? tile.h : 2


	// onTileChanged: console.log('onTileChanged', JSON.stringify(tile))
	// onAppLabelChanged: console.log('onAppLabelChanged', appLabel)
}
