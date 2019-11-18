import QtQuick 2.0

import "../lib"
import "../lib/Requests.js" as Requests

Item {
	id: session

	Logger {
		id: logger
		showDebug: plasmoid.configuration.debugging
	}

	// Client
	property string clientId: plasmoid.configuration.client_id
	property string clientSecret: plasmoid.configuration.client_secret

	// New Session
	property string deviceCode: ''
	property string userCode: ''
	property int userCodeExpiresAt: 0
	property int userCodePollInterval: 0

	// Active Session
	readonly property string accessToken: plasmoid.configuration.access_token
	readonly property string accessTokenType: plasmoid.configuration.access_token_type
	readonly property int accessTokenExpiresAt: plasmoid.configuration.access_token_expires_at
	readonly property string refreshToken: plasmoid.configuration.refresh_token

	// Data
	property var calendarListData: ConfigSerializedString {
		id: calendarListData
		configKey: 'calendar_list'
		defaultValue: []
	}
	property alias calendarList: calendarListData.value

	property var calendarIdListData: ConfigSerializedString {
		id: calendarIdListData
		configKey: 'calendar_id_list'
		defaultValue: []

		function serialize() {
			plasmoid.configuration[configKey] = value.join(',')
		}
		function deserialize() {
			value = configValue.split(',')
		}
	}
	property alias calendarIdList: calendarIdListData.value

	signal newAccessToken()
	signal sessionReset()
	signal error(string err)


	//---
	readonly property string authorizationCodeUrl: {
		var url = 'https://accounts.google.com/o/oauth2/v2/auth'
		url += '?scope=' + encodeURIComponent('https://www.googleapis.com/auth/calendar https://www.googleapis.com/auth/tasks')
		url += '&response_type=code'
		url += '&redirect_uri=' + encodeURIComponent('urn:ietf:wg:oauth:2.0:oob')
		url += '&client_id=' + encodeURIComponent(clientId)
		return url
	}

	function fetchAccessToken(args) {
		var url = 'https://www.googleapis.com/oauth2/v4/token'
		Requests.post({
			url: url,
			data: {
				client_id: clientId,
				client_secret: clientSecret,
				code: args.authorizationCode,
				grant_type: 'authorization_code',
				redirect_uri: 'urn:ietf:wg:oauth:2.0:oob',
			},
		}, function(err, data) {
			data = JSON.parse(data)
			logger.debugJSON('/oauth2/v4/token Response', data)

			// Check for errors
			if (err || data.error) {
				handleError(err, data)
				return
			}

			// Ready
			updateAccessToken(data)
		})
	}

	function updateAccessToken(data) {
		plasmoid.configuration.access_token = data.access_token
		plasmoid.configuration.access_token_type = data.token_type
		plasmoid.configuration.access_token_expires_at = Date.now() + data.expires_in * 1000
		plasmoid.configuration.refresh_token = data.refresh_token
		newAccessToken()
	}

	onNewAccessToken: updateCalendarList()

	function updateCalendarList() {
		logger.debug('updateCalendarList')
		logger.debug('access_token', accessToken)
		fetchGCalCalendars({
			access_token: accessToken,
		}, function(err, data, xhr) {
			// Check for errors
			if (err || data.error) {
				handleError(err, data)
				return
			}
			calendarListData.value = data.items
		})
	}

	function fetchGCalCalendars(args, callback) {
		var url = 'https://www.googleapis.com/calendar/v3/users/me/calendarList'
		Requests.getJSON({
			url: url,
			headers: {
				"Authorization": "Bearer " + args.access_token,
			}
		}, function(err, data, xhr) {
			// console.log('fetchGCalCalendars.response', err, data, xhr.status)
			if (!err && data && data.error) {
				return callback('fetchGCalCalendars error', data, xhr)
			}
			callback(err, data, xhr)
		})
	}

	function reset() {
		plasmoid.configuration.access_token = ''
		plasmoid.configuration.access_token_type = ''
		plasmoid.configuration.access_token_expires_at = 0
		plasmoid.configuration.refresh_token = ''

		// Delete relevant data
		// TODO: only target google calendar data
		// TODO: Make a signal?
		plasmoid.configuration.agenda_newevent_last_calendar_id = ''
		calendarList = []
		calendarIdList = []
		sessionReset()
	}

	// https://developers.google.com/calendar/v3/errors
	function handleError(err, data) {
		if (data.error && data.error_description) {
			var errorMessage = '' + data.error + ' (' + data.error_description + ')'
			session.error(errorMessage)
		} else if (data.error && data.error.message && typeof data.error.code !== "undefined") {
			var errorMessage = '' + data.error.message + ' (' + data.error.code + ')'
			session.error(errorMessage)
		} else if (err) {
			session.error(err)
		}
	}
}
