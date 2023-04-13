import QtQuick 2.0

import "../lib"
import "../lib/Requests.js" as Requests

Item {
	id: session
	ExecUtil { id: executable }
	property int callbackListenPort: 8001

	Logger {
		id: logger
		showDebug: plasmoid.configuration.debugging
	}

	// Active Session
	readonly property bool isLoggedIn: !!plasmoid.configuration.accessToken
	readonly property bool needsRelog: {
		if (plasmoid.configuration.accessToken && plasmoid.configuration.latestClientId != plasmoid.configuration.sessionClientId) {
			return true
		} else if (!plasmoid.configuration.accessToken && plasmoid.configuration.access_token) {
			return true
		} else {
			return false
		}
	}

	// Data
	property var m_calendarList: ConfigSerializedString {
		id: m_calendarList
		configKey: 'calendarList'
		defaultValue: []
	}
	property alias calendarList: m_calendarList.value

	property var m_calendarIdList: ConfigSerializedString {
		id: m_calendarIdList
		configKey: 'calendarIdList'
		defaultValue: []

		function serialize() {
			plasmoid.configuration[configKey] = value.join(',')
		}
		function deserialize() {
			value = configValue.split(',')
		}
	}
	property alias calendarIdList: m_calendarIdList.value

	property var m_tasklistList: ConfigSerializedString {
		id: m_tasklistList
		configKey: 'tasklistList'
		defaultValue: []
	}
	property alias tasklistList: m_tasklistList.value

	property var m_tasklistIdList: ConfigSerializedString {
		id: m_tasklistIdList
		configKey: 'tasklistIdList'
		defaultValue: []

		function serialize() {
			plasmoid.configuration[configKey] = value.join(',')
		}
		function deserialize() {
			value = configValue.split(',')
		}
	}
	property alias tasklistIdList: m_tasklistIdList.value


	//--- Signals
	signal newAccessToken()
	signal sessionReset()
	signal error(string err)

    readonly property string authorizationCodeUrl: {
        var url = 'https://accounts.google.com/o/oauth2/v2/auth'
        url += '?scope=' + encodeURIComponent('https://www.googleapis.com/auth/calendar https://www.googleapis.com/auth/tasks')
        url += '&response_type=code'
        url += '&redirect_uri=' + "http://127.0.0.1:" + callbackListenPort.toString() + "/"
        url += '&client_id=' + encodeURIComponent(plasmoid.configuration.latestClientId)
        return url
    }


	function fetchAccessToken() {
		var cmd = [
			'python3',
			plasmoid.file("", "scripts/google_redirect.py"),
            "--client_id", plasmoid.configuration.latestClientId,
            "--client_secret", plasmoid.configuration.latestClientSecret,
            "--listen_port", callbackListenPort.toString(),
		]

        Qt.openUrlExternally(authorizationCodeUrl);

		executable.exec(cmd, function(cmd, exitCode, exitStatus, stdout, stderr) {
			if (exitCode) {
				logger.log('fetchAccessToken.stderr', stderr)
				logger.log('fetchAccessToken.stdout', stdout)
				return
			}

			try {
				var data = JSON.parse(stdout)
				updateAccessToken(data)
			} catch (e) {
				logger.log('fetchAccessToken.e', e)
				handleError('Error parsing JSON', null)
				return
			}

		})
	}

	function updateAccessToken(data) {
		plasmoid.configuration.sessionClientId = plasmoid.configuration.latestClientId
		plasmoid.configuration.sessionClientSecret = plasmoid.configuration.latestClientSecret
		plasmoid.configuration.accessToken = data.access_token
		plasmoid.configuration.accessTokenType = data.token_type
		plasmoid.configuration.accessTokenExpiresAt = Date.now() + data.expires_in * 1000
		plasmoid.configuration.refreshToken = data.refresh_token
		newAccessToken()
	}

	onNewAccessToken: updateData()

	function updateData() {
		updateCalendarList()
		updateTasklistList()
	}

	function updateCalendarList() {
		logger.debug('updateCalendarList')
		logger.debug('accessToken', plasmoid.configuration.accessToken)
		fetchGCalCalendars({
			accessToken: plasmoid.configuration.accessToken,
		}, function(err, data, xhr) {
			// Check for errors
			if (err || data.error) {
				handleError(err, data)
				return
			}
			m_calendarList.value = data.items
		})
	}

	function fetchGCalCalendars(args, callback) {
		var url = 'https://www.googleapis.com/calendar/v3/users/me/calendarList'
		Requests.getJSON({
			url: url,
			headers: {
				"Authorization": "Bearer " + args.accessToken,
			}
		}, function(err, data, xhr) {
			// console.log('fetchGCalCalendars.response', err, data, xhr && xhr.status)
			if (!err && data && data.error) {
				return callback('fetchGCalCalendars error', data, xhr)
			}
			logger.debugJSON('fetchGCalCalendars.response.data', data)
			callback(err, data, xhr)
		})
	}

	function updateTasklistList() {
		logger.debug('updateTasklistList')
		logger.debug('accessToken', plasmoid.configuration.accessToken)
		fetchGoogleTasklistList({
			accessToken: plasmoid.configuration.accessToken,
		}, function(err, data, xhr) {
			// Check for errors
			if (err || data.error) {
				handleError(err, data)
				return
			}
			m_tasklistList.value = data.items
		})
	}

	function fetchGoogleTasklistList(args, callback) {
		var url = 'https://www.googleapis.com/tasks/v1/users/@me/lists'
		Requests.getJSON({
			url: url,
			headers: {
				"Authorization": "Bearer " + args.accessToken,
			}
		}, function(err, data, xhr) {
			console.log('fetchGoogleTasklistList.response', err, data, xhr && xhr.status)
			if (!err && data && data.error) {
				return callback('fetchGoogleTasklistList error', data, xhr)
			}
			logger.debugJSON('fetchGoogleTasklistList.response.data', data)
			callback(err, data, xhr)
		})
	}

	function logout() {
		plasmoid.configuration.sessionClientId = ''
		plasmoid.configuration.sessionClientSecret = ''
		plasmoid.configuration.accessToken = ''
		plasmoid.configuration.accessTokenType = ''
		plasmoid.configuration.accessTokenExpiresAt = 0
		plasmoid.configuration.refreshToken = ''

		// Delete relevant data
		// TODO: only target google calendar data
		// TODO: Make a signal?
		plasmoid.configuration.agendaNewEventLastCalendarId = ''
		calendarList = []
		calendarIdList = []
		tasklistList = []
		tasklistIdList = []
		sessionReset()
	}

	// https://developers.google.com/calendar/v3/errors
	function handleError(err, data) {
		if (data && data.error && data.error_description) {
			var errorMessage = '' + data.error + ' (' + data.error_description + ')'
			session.error(errorMessage)
		} else if (data && data.error && data.error.message && typeof data.error.code !== "undefined") {
			var errorMessage = '' + data.error.message + ' (' + data.error.code + ')'
			session.error(errorMessage)
		} else if (err) {
			session.error(err)
		}
	}
}
