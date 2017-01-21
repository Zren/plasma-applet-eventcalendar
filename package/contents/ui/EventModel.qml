import QtQuick 2.0
import QtQuick.Layouts 1.1

import org.kde.plasma.core 2.0 as PlasmaCore

import "utils.js" as Utils
import "shared.js" as Shared
import "../code/DebugFixtures.js" as DebugFixtures

Item {
	id: eventModel
	property variant eventsData: { "items": [] }
	property variant eventsByCalendar: { "": { "items": [] } }
	property date dateMin: new Date()
	property date dateMax: new Date()

	property int asyncRequests: 0
	property int asyncRequestsDone: 0
	signal dataCleared()
	signal fetchingData()
	signal calendarFetched(string calendarId, var data)
	signal allDataFetched()

	onAsyncRequestsDoneChanged: checkIfDone()

	Component.onCompleted: {
		delete eventModel.eventsByCalendar[''] // Is there really no way to initialize an empty JSON object?
	}

	function clear() {
		console.log('eventModel.clear()')
		asyncRequests = 0
		asyncRequestsDone = 0
		eventModel.eventsByCalendar = {}
		dataCleared()
	}

	function setCalendarData(calendarId, data) {
		eventModel.eventsByCalendar[calendarId] = data
		calendarFetched(calendarId, data)
	}

	function update() {
		fetchAllEvents(dateMin, dateMax)
	}

	function fetchAllEvents(dateMin, dateMax) {
		console.log('fetchAllEvents', dateMin, dateMax)
		fetchingData()
		clear()
		eventModel.dateMin = dateMin
		eventModel.dateMax = dateMax
		// fetchDebugEvents()
		fetchGoogleAccountData()
		checkIfDone()
	}

	function checkIfDone() {
		if (asyncRequestsDone >= asyncRequests) {
			allDataFetched()
		}
	}

	function fetchDebugEvents() {
		setCalendarData('debug', DebugFixtures.getEventData())
		fetchDebugGoogleSession()
	}

	function fetchDebugGoogleSession() {
		// Steal access_token from our current user's config.
		fetchCurrentUserConfig(function(err, metadata) {
			var accessToken = metadata['access_token']
			var calendarIdList = metadata['calendar_id_list'].split(',')
			console.log('fetchDebugGoogleSession', accessToken, calendarIdList)
			fetchGoogleAccountEvents(accessToken, calendarIdList)
		})
	}

	function fetchCurrentUserConfig(callback) {
		var url = 'file:///home/chris/.config/plasma-org.kde.plasma.desktop-appletsrc'
		Utils.getFile(url, function(err, data) {
			if (err) {
				return callback(err);
			}

			var metadata = Utils.parseMetadata(data)
			callback(null, metadata);
		});
	}

	function fetchGoogleAccountData() {
		if (plasmoid.configuration.access_token) {
			var calendarIdList = plasmoid.configuration.calendar_id_list ? plasmoid.configuration.calendar_id_list.split(',') : ['primary']
			fetchGoogleAccountEvents(plasmoid.configuration.access_token, calendarIdList)
		}
	}

	function fetchGoogleAccountEvents(accessToken, calendarIdList) {
		if (accessToken) {
			for (var i = 0; i < calendarIdList.length; i++) {
				fetchGoogleCalendarEvents(accessToken, calendarIdList[i])
			}
		}
	}

	// @param accessToken string
	// @param calendarId string
	// @param dateMin Date
	// @param dateMax Date
	function fetchGoogleCalendarEvents(accessToken, calendarId) {
		console.log('fetchGoogleCalendarEvents', calendarId)
		eventModel.asyncRequests += 1
		fetchGCalEvents({
			calendarId: calendarId,
			start: eventModel.dateMin.toISOString(),
			end: eventModel.dateMax.toISOString(),
			access_token: accessToken,
		}, function(err, data, xhr) {
			if (err) {
				if (typeof err === 'object') {
					console.log('err: ', JSON.stringify(err, null, '\t'));
				} else {
					console.log('err: ', err);
				}
				if (xhr.status === 404) {
					return;
				}
				eventModel.asyncRequestsDone += 1
				return onGCalError(err);
			}

			setCalendarData(calendarId, data)
			eventModel.asyncRequestsDone += 1
		});
	}

	function onGCalError(err) {
		if (typeof err === 'object') {
			console.log('onGCalError: ', JSON.stringify(err, null, '\t'));
		} else {
			console.log('onGCalError: ', err);
		}
		
		// updateAccessToken();
	}

	function fetchNewAccessToken(callback) {
		console.log('fetchNewAccessToken');
		var url = 'https://www.googleapis.com/oauth2/v4/token';
		Utils.post({
			url: url,
			data: {
				client_id: plasmoid.configuration.client_id,
				client_secret: plasmoid.configuration.client_secret,
				refresh_token: plasmoid.configuration.refresh_token,
				grant_type: 'refresh_token',
			},
		}, callback);
	}

	function updateAccessToken() {
		// console.log('access_token_expires_at', plasmoid.configuration.access_token_expires_at);
		// console.log('                    now', Date.now());
		// console.log('refresh_token', plasmoid.configuration.refresh_token);
		if (plasmoid.configuration.refresh_token) {
			console.log('fetchNewAccessToken');
			fetchNewAccessToken(function(err, data, xhr) {
				if (err || (!err && data && data.error)) {
					return console.log('Error when using refreshToken:', err, data);
				}
				console.log('onAccessToken', data);
				data = JSON.parse(data);

				plasmoid.configuration.access_token = data.access_token;
				plasmoid.configuration.access_token_type = data.token_type;
				plasmoid.configuration.access_token_expires_at = Date.now() + data.expires_in * 1000;

				// eventModel.update()
			});
		}
	}

	function fetchGCalEvents(args, callback) {
		console.log('fetchGCalEvents', args.calendarId);
		var url = 'https://www.googleapis.com/calendar/v3';
		url += '/calendars/'
		url += encodeURIComponent(args.calendarId);
		url += '/events';
		url += '?timeMin=' + encodeURIComponent(args.start);
		url += '&timeMax=' + encodeURIComponent(args.end);
		url += '&singleEvents=' + encodeURIComponent('true');
		url += '&timeZone=' + encodeURIComponent('Etc/UTC');
		Utils.getJSON({
			url: url,
			headers: {
				"Authorization": "Bearer " + args.access_token,
			}
		}, function(err, data, xhr) {
			console.log('fetchGCalEvents.response', args.calendarId, err, data, xhr.status);
			if (!err && data && data.error) {
				return callback(data, null, xhr);
			}
			callback(err, data, xhr);
		});
	}
}
