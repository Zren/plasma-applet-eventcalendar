import QtQuick 2.0

ListModel {
	id: listModel
	
	property var list: []

	signal refreshing()
	signal refreshed()

	onListChanged: {
		clear()
		for (var i = 0; i < list.length; i++) {
			append(list[i]);
		}
	}


	function parseAppsModelItem(model, i) {
		// https://github.com/KDE/plasma-desktop/blob/master/applets/kicker/plugin/actionlist.h#L30
		var DescriptionRole = Qt.UserRole + 1;
		var GroupRole = DescriptionRole + 1;
		var FavoriteIdRole = DescriptionRole + 2;
		var IsSeparatorRole = DescriptionRole + 3;
		var IsDropPlaceholderRole = DescriptionRole + 4;
		var IsParentRole = DescriptionRole + 5;
		var HasChildrenRole = DescriptionRole + 6;
		var HasActionListRole = DescriptionRole + 7;
		var ActionListRole = DescriptionRole + 8;
		var UrlRole = DescriptionRole + 9;

		var modelIndex = model.index(i, 0);

		var item = {
			parentModel: model,
			indexInParent: i,
			parentName: model.name,
			name: model.data(modelIndex, Qt.DisplayRole),
			description: model.data(modelIndex, DescriptionRole),
		};

		// ListView.append() doesn't like it when we have { key: [object] }.
		var url = model.data(modelIndex, UrlRole);
		if (typeof url === 'object') {
			url = url.toString();
		}
		item.url = url;

		var icon =  model.data(modelIndex, Qt.DecorationRole);
		item.icon = typeof icon === 'object' ? icon : undefined;
		item.iconName = typeof icon === 'string' ? icon : undefined;

		return item;
	}

	function parseModel(appList, model, path) {
		// console.log(path, model, model.description, model.count);
		for (var i = 0; i < model.count; i++) {
			var item = model.modelForRow(i);
			if (!item) {
				item = parseAppsModelItem(model, i);
			}
			var itemPath = (path || []).concat(i);
			if (item && item.hasChildren) {
				// console.log(item)
				parseModel(appList, item, itemPath);
			} else {
				// console.log(itemPath, item, item.description);
				appList.push(item);
			}
		}
	}


	function refresh() {
		refreshing()

		refreshed()
	}

	function log() {
		for (var i = 0; i < list.length; i++) {
			var item = list[i];
			console.log(JSON.stringify({
				name: item.name,
				description: item.description,
			}, null, '\t'))
		}
	}

	function triggerIndex(index) {
		var item = list[index]
		item.parentModel.trigger(item.indexInParent, "", null);
		itemTriggered()
	}
	
	signal itemTriggered()
}
