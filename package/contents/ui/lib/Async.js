.pragma library
// Version 1

function _taskCallback(asyncObj, key, err, taskResult) {
	asyncObj.numCompleted += 1
	if (err) {
		asyncObj.err = err
		asyncObj.finalCallback(err)
	} else if (asyncObj.err) {
		// Skip
	} else {
		asyncObj.results[key] = taskResult
		if (asyncObj.numCompleted >= asyncObj.numTasks) {
			asyncObj.finalCallback(null, asyncObj.results)
		}
	}
}

// http://caolan.github.io/async/docs.html#parallel
function parallel(tasks, finalCallback) {
	if (tasks.length == 0) {
		finalCallback(null, [])
	} else {
		var asyncObj = {}
		asyncObj.numTasks = tasks.length // Serialize in case the array changes size
		asyncObj.numCompleted = 0
		asyncObj.err = null
		asyncObj.results = []
		asyncObj.finalCallback = finalCallback

		for (var i = 0; i < tasks.length; i++) {
			var task = tasks[i]
			var taskCallback = _taskCallback.bind(null, asyncObj, i)
			task(taskCallback)
		}
	}
}

/*
** Example
*/
// parallel([
// 	function(callback) {
// 		setTimeout(function() {
// 			callback(null, 'one');
// 		}, 200);
// 	},
// 	function(callback) {
// 		setTimeout(function() {
// 			callback(null, 'two');
// 		}, 100);
// 	},
// ], function(err, results) {
// 	console.log('done', results)
// })
