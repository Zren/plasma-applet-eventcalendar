import QtQuick 2.0

QtObject {
	id: timerModel

	property int secondsLeft: 0
	property int duration: 0
	readonly property bool timerRepeats: plasmoid.configuration.timer_repeats
	readonly property bool timerSfxEnabled: plasmoid.configuration.timer_sfx_enabled
	readonly property string timerSfxFilepath:  plasmoid.configuration.timer_sfx_filepath
	property alias running: timerTicker.running

	signal timerFinished()

	function getHours(t) {
		var hours = Math.floor(t / (60 * 60 * 1000))
		return hours
	}
	function getMinutes(t) {
		var millisLeftInHour = t % (60 * 60 * 1000)
		var minutes = millisLeftInHour / (60 * 1000)
		return minutes
	}
	function getSeconds(t) {
		var millisLeftInMinute = t % (60 * 1000)
		var seconds = millisLeftInMinute / 1000
		return seconds
	}
	function durationShortFormat(nSeconds) {
		var t = nSeconds * 1000
		var str = ''
		var hours = Math.floor(getHours(t))
		if (hours > 0) {
			str += i18nc("short form for %1 hours", "%1h", hours)
		}
		var minutes = Math.floor(getMinutes(t))
		if (minutes > 0) {
			str += i18nc("short form for %1 minutes", "%1m", minutes)
		}
		var seconds = Math.floor(getSeconds(t))
		if (seconds > 0) {
			str += i18nc("short form for %1 seconds", "%1s", seconds)
		}
		return str
	}
	property var defaultTimers: [
		{ seconds: 30 },
		{ seconds: 60 },
		{ seconds: 5 * 60 },
		{ seconds: 10 * 60 },
		{ seconds: 15 * 60 },
		{ seconds: 20 * 60 },
		{ seconds: 30 * 60 },
		{ seconds: 45 * 60 },
		{ seconds: 60 * 60 },
	]

	property Timer timerTicker: Timer {
		id: timerTicker
		interval: 1000
		running: false
		repeat: true

		onTriggered: {
			timerModel.secondsLeft -= 1
		}
	}

	function setDuration(newDuration) {
		if (newDuration <= 0) {
			return
		}
		timerModel.duration = newDuration
		timerModel.secondsLeft = newDuration
	}

	function setDurationAndStart(newDuration) {
		setDuration(newDuration)
		if (newDuration > 0) {
			timerTicker.restart()
		}
	}

	function getIncrementFor(oldDuration, multiplier) {
		if (oldDuration >= 15 * 60) { // 15m
			return 5 * 60 // +5m
		} else if (oldDuration >= 60) { // 1m
			if (multiplier < 0 && oldDuration < 120) { // 1-2m -5sec
				return 5 // -5sec
			} else {
				return 60 // +1m
			}
		} else if (oldDuration >= 15) { // 15sec
			return 5 // +5sec
		} else { 
			if (multiplier < 0 && oldDuration <= 1) { // 0-1sec
				return 0 // +0
			} else { // 2-14sec
				return 1 // +5sec
			}
		}
	}
	function deltaDuration(multiplier) {
		var delta = getIncrementFor(duration, multiplier)
		var newDuration = Math.max(0, timerModel.duration + (delta * multiplier))
		// console.log(timerModel.duration, multiplier, delta, newDuration)
		setDuration(newDuration)
	}
	function increaseDuration() {
		deltaDuration(1)
	}
	function decreaseDuration() {
		deltaDuration(-1)
	}

	onDurationChanged: {
		secondsLeft = duration
	}

	onSecondsLeftChanged: {
		// console.log('onSecondsLeftChanged', secondsLeft)
		if (secondsLeft <= 0) {
			timerFinished()
		}
	}

	function formatTimer(nSeconds) {
		// returns "1:00:00" or "10:00" or "0:01"
		var hours = Math.floor(nSeconds / 3600)
		var minutes = Math.floor((nSeconds - hours*3600) / 60)
		var seconds = nSeconds - hours*3600 - minutes*60
		var s = "" + (seconds < 10 ? "0" : "") + seconds
		s = minutes + ":" + s
		if (hours > 0) {
			s = hours + ":" + (minutes < 10 ? "0" : "") + s
		}
		return s
	}

	function repeatTimer() {
		timerModel.secondsLeft = timerModel.duration
		timerTicker.start()
	}

	function start() {
		timerTicker.start()
	}

	function restart() {
		timerTicker.restart()
	}

	function stop() {
		timerTicker.stop()
	}

	onTimerFinished: {
		timerTicker.stop()
		createNotification()

		if (timerRepeats) {
			repeatTimer()
		}
	}

	function createNotification() {
		var args = {
			appName: i18n("Timer"),
			appIcon: "chronometer",
			summary: i18n("Timer finished"),
			body: i18n("%1 has passed", formatTimer(timerModel.duration)),
			expireTimeout: 2000,
		}
		if (timerModel.timerSfxEnabled) {
			args.soundFile = timerModel.timerSfxFilepath
		}

		args.actions = []
		if (!timerModel.timerRepeats) {
			var action = 'repeat' + ',' + i18n("Repeat")
			args.actions.push(action)
		}
		notificationManager.notify(args, function(actionId){
			if (actionId == 'repeat') {
				repeatTimer()
			}
		})
	}
}
