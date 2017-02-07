import QtQuick 2.0

Item {
	id: logger
	property string name: 'logger'
	property bool showDebug: false

	function debug() {
		if (showDebug) {
			var args = Array.apply(null, arguments)
			args.unshift('[' + name + ':debug]')
			console.log.apply(console, args)
		}
	}
	
	function log() {
		var args = Array.apply(null, arguments)
		args.unshift('[' + name + ']')
		console.log.apply(console, args)
	}
}
