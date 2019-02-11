// Version 3

import QtQuick 2.0
import QtQuick.LocalStorage 2.0

// http://doc.qt.io/qt-5/qtquick-localstorage-qmlmodule.html
QtObject {
	id: localDb
	property string name
	property string version: "1"
	property string description: ""
	property int estimatedSize: 1 * 1024 * 1024 // 1 MiB
	property var db: null

	property var loggerObj: Logger {
		id: logger
		name: 'localdb'
		// showDebug: true
	}
	property alias showDebug: logger.showDebug

	signal setupTables(var tx)

	property var keyValue: initTable('KeyValue')

	function initTable(tableName) {
		var tableObj = {}
		tableObj.tableName = tableName
		tableObj.createTable = localDb.createTable.bind(localDb, tableName)
		tableObj.createKeyValueTableSql = localDb.createKeyValueTableSql.bind(localDb, tableName)
		tableObj.get = localDb.get.bind(localDb, tableName)
		tableObj.getJSON = localDb.getJSON.bind(localDb, tableName)
		tableObj.set = localDb.set.bind(localDb, tableName)
		tableObj.setJSON = localDb.setJSON.bind(localDb, tableName)
		tableObj.getAll = localDb.getAll.bind(localDb, tableName)
		tableObj.getAllAsMap = localDb.getAllAsMap.bind(localDb, tableName)
		tableObj.getAllAsList = localDb.getAllAsList.bind(localDb, tableName)
		tableObj.deleteAll = localDb.deleteAll.bind(localDb, tableName)
		tableObj.getOrFetchJSON = localDb.getOrFetchJSON.bind(localDb, tableName)
		return tableObj
	}

	function createKeyValueTableSql(tableName) {
		// Create the database if it doesn't already exist
		var sql = 'CREATE TABLE IF NOT EXISTS ' + tableName + '('
		sql += 'name TEXT NOT NULL PRIMARY KEY,'
		sql += 'dataStr TEXT,'
		sql += 'created_at timestamp NOT NULL DEFAULT current_timestamp,'
		sql += 'updated_at timestamp NOT NULL DEFAULT current_timestamp)'
		return sql
	}

	function createTable(tableName, tx) {
		var sql = createKeyValueTableSql(tableName)
		tx.executeSql(sql)
	}

	function initDb(callback) {
		logger.debug('initDb.start')
		db = LocalStorage.openDatabaseSync(name, version, description, estimatedSize)

		db.transaction(function(tx) {
			keyValue.createTable(tx)
			setupTables(tx)
			logger.debug('initDb.ready')
			callback(null)
		})
	}

	function get(tableName, key, callback) {
		db.transaction(function(tx) {
			var rs = tx.executeSql('SELECT * FROM ' + tableName + ' WHERE name = ?', key)
			var row = null
			if (rs.rows.length >= 1) {
				var row = rs.rows.item(0)
			}
			logger.debug('db.get', key, row && row.updated_at, row && row.dataStr)
			callback(null, row)
		})
	}

	function getJSON(tableName, key, callback) {
		get(tableName, key, function(err, row){
			if (err) {
				callback(err, null, row)
			} else {
				if (row) {
					var data = row.dataStr
					if (row.dataStr) {
						data = JSON.parse(data)
					}
					callback(null, data, row)
				} else {
					callback(null, null, null)
				}
			}
		})
	}

	function set(tableName, key, value, callback) {
		db.transaction(function(tx) {
			tx.executeSql('INSERT OR REPLACE INTO ' + tableName + '(name, dataStr, updated_at) VALUES (?, ?, current_timestamp)', [key, value])
			logger.debug('db.set', key, value)
			callback(null)
		})
	}

	function setJSON(tableName, key, value, callback) {
		var dataStr = JSON.stringify(value)
		set(tableName, key, dataStr, callback)
	}



	function getAll(tableName, callback) {
		db.transaction(function(tx) {
			var rs = tx.executeSql('SELECT * FROM ' + tableName)
			logger.debug('db.getAll', rs.rows.length)
			callback(null, rs.rows)
		})
	}
	function getAllAsMap(tableName, callback) {
		getAll(tableName, function(err, rows){
			logger.debug('db.getAllAsMap', rows.length)
			if (err) {
				callback(err, null, rows)
			} else {
				var data = {}
				for (var i = 0; i < rows.length; i++) {
					var row = rows[i]
					if (row.dataStr) {
						data[row.name] = JSON.parse(row.dataStr)
					} else {
						data[row.name] = null
					}
				}
				callback(err, data, rows)
			}
		})
	}
	function getAllAsList(tableName, callback) {
		getAll(tableName, function(err, rows){
			logger.debug('db.getAllAsList', rows.length)
			if (err) {
				callback(err, null, rows)
			} else {
				var arr = []
				for (var i = 0; i < rows.length; i++) {
					var row = rows[i]
					var value = row.dataStr ? JSON.parse(row.dataStr) : null
					var item = {
						key: row.name,
						value: value,
					}
					arr.push(item)
				}
				callback(null, arr, rows)
			}
		})
	}

	function deleteAll(tableName, callback) {
		logger.debug('db.deleteAll.start')
		db.transaction(function(tx) {
			var rs = tx.executeSql('DELETE FROM ' + tableName)
			logger.debug('db.deleteAll.done')
			callback(null)
		})
	}

	function hasExpired(dt, ttl) {
		var now = new Date()
		var diff = now.getTime() - dt.getTime()
		return diff >= ttl
	}

	function getOrFetchJSON(tableName, key, ttl, populate, callback) {
		localDb.getJSON(tableName, key, function(err, data, row){
			var shouldUpdate = true
			if (data) {
				// Can we assume the timestamp is always UTC?
				// The 'Z' parses the timestamp in UTC.
				// Maybe check the length of the string?
				var rowUpdatedAt = new Date(row.updated_at + 'Z')
				shouldUpdate = hasExpired(rowUpdatedAt, ttl)
			}
			logger.debug('db.getOrFetchJSON', key, '(shouldUpdate=', shouldUpdate, ')')

			if (shouldUpdate) {
				populate(function(err, data) {
					localDb.setJSON(tableName, key, data, function(err){
						callback(err, data)
					})
				})
			} else {
				callback(err, data)
			}
		})
	}
}
