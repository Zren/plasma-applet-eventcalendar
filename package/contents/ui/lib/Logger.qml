// Version 1

import QtQuick 2.0

Item {
	id: logger
	property string name: 'logger'
	property bool showDebug: false

	function prettifyArguments(rawArgs) {
		var args = Array.apply(null, rawArgs)
		for (var i = 0; i < args.length; i++) {
			if (typeof args[i] === "object" || args[i] instanceof Array) {
				args[i] = JSON.stringify(args[i], null, '\t')
			}
		}
		return args
	}

	function debug() {
		if (showDebug) {
			var args = Array.apply(null, arguments)
			args.unshift('[' + name + ':debug]')
			console.log.apply(console, args)
		}
	}

	function debugJSON() {
		if (showDebug) {
			var args = prettifyArguments(arguments)
			args.unshift('[' + name + ':debug]')
			console.log.apply(console, args)
		}
	}

	function log() {
		var args = Array.apply(null, arguments)
		args.unshift('[' + name + ']')
		console.log.apply(console, args)
	}

	function logJSON() {
		if (showDebug) {
			var args = prettifyArguments(arguments)
			args.unshift('[' + name + ']')
			console.log.apply(console, args)
		}
	}
}
