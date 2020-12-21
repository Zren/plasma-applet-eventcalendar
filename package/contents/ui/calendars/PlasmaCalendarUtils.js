.pragma library

// https://github.com/KDE/plasma-framework/blob/master/src/declarativeimports/calendar/eventpluginsmanager.h
// https://github.com/KDE/plasma-framework/blob/master/src/declarativeimports/calendar/eventpluginsmanager.cpp

function getPluginFilename(pluginPath) {
	return pluginPath.substr(pluginPath.lastIndexOf('/') + 1)
}

function pluginPathToFilenameList(pluginPathList) {
	var pluginFilenameList = new Array(pluginPathList.length)
	for (var i = 0; i < pluginPathList.length; i++) {
		pluginFilenameList[i] = getPluginFilename(pluginPathList[i])
	}
	return pluginFilenameList
}

function getPluginPath(eventPluginsManager, pluginFilenameA) {
	for (var i = 0; i < eventPluginsManager.model.rowCount(); i++) {
		var pluginPath = eventPluginsManager.model.get(i, 'pluginPath')
		// console.log('\t\t', i, pluginPath)
		var pluginFilenameB = getPluginFilename(pluginPath)
		if (pluginFilenameA == pluginFilenameB) {
			return pluginPath
		}
	}

	// Plugin not installed
	return null
}

function pluginFilenameToPathList(eventPluginsManager, pluginFilenameList) {
	// console.log('eventPluginsManager', eventPluginsManager)
	// console.log('eventPluginsManager.model', eventPluginsManager.model)
	// console.log('eventPluginsManager.model.rowCount', eventPluginsManager.model.rowCount())
	var pluginPathList = []
	for (var i = 0; i < pluginFilenameList.length; i++) {
		var pluginFilename = pluginFilenameList[i]
		// console.log('\t\t', i, pluginFilename)
		var pluginPath = getPluginPath(eventPluginsManager, pluginFilename)
		if (!pluginPath) {
			console.log('[eventcalendar] Tried to load ', pluginFilename, ' however the plasma calendar plugin is not installed.')
			continue
		}
		pluginPathList.push(pluginPath)
	}
	// console.log('pluginFilenameList', pluginFilenameList)
	// console.log('pluginPathList', pluginPathList)
	return pluginPathList
}

function populateEnabledPluginsByFilename(eventPluginsManager, pluginFilenameList) {
	var pluginPathList = pluginFilenameToPathList(eventPluginsManager, pluginFilenameList)
	eventPluginsManager.populateEnabledPluginsList(pluginPathList)
}

function setEnabledPluginsByFilename(eventPluginsManager, pluginFilenameList) {
	var pluginPathList = pluginFilenameToPathList(eventPluginsManager, pluginFilenameList)
	eventPluginsManager.enabledPlugins = pluginPathList
}

