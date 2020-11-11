.pragma library

// Google Calendar Errors are documented at:
// https://developers.google.com/calendar/v3/errors

function testCouldNotConnect(callback) {
	var err = 'HTTP 0'
	var data = null
	var xhr = { status: 0 }
	return callback(err, data, xhr)
}

function testInvalidCredentials(callback) {
	var err = {
		"error": {
			"errors": [
				{
					"domain": "global",
					"reason": "authError",
					"message": "Invalid Credentials",
					"locationType": "header",
					"location": "Authorization",
				}
			],
			"code": 401,
			"message": "Invalid Credentials"
		}
	}
	var data = null
	var xhr = { status: err.error.code }
	return callback(err, data, xhr)
}

function testDailyLimitExceeded(callback) {
	var err = {
		"error": {
			"errors": [
				{
					"domain": "usageLimits",
					"reason": "dailyLimitExceeded",
					"message": "Daily Limit Exceeded"
				}
			],
			"code": 403,
			"message": "Daily Limit Exceeded"
		}
	}
	var data = null
	var xhr = { status: err.error.code }
	return callback(err, data, xhr)
}

function testUserRateLimitExceeded(callback) {
	var err = {
		"error": {
			"errors": [
				{
					"domain": "usageLimits",
					"reason": "userRateLimitExceeded",
					"message": "User Rate Limit Exceeded"
				}
			],
			"code": 403,
			"message": "User Rate Limit Exceeded"
		}
	}
	var data = null
	var xhr = { status: err.error.code }
	return callback(err, data, xhr)
}

function testRateLimitExceeded(callback) {
	var err = {
		"error": {
			"errors": [
				{
					"domain": "usageLimits",
					"reason": "rateLimitExceeded",
					"message": "Rate Limit Exceeded"
				}
			],
			"code": 403,
			"message": "Rate Limit Exceeded"
		}
	}
	var data = null
	var xhr = { status: err.error.code }
	return callback(err, data, xhr)
}

function testBackendError(callback) {
	var err = {
		"error": {
			"errors": [
				{
					"domain": "global",
					"reason": "backendError",
					"message": "Backend Error",
				}
			],
			"code": 500,
			"message": "Backend Error"
		}
	}
	var data = null
	var xhr = { status: err.error.code }
	return callback(err, data, xhr)
}
