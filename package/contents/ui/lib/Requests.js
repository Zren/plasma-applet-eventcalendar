.pragma library

function request(opt, callback) {
	if (typeof opt === 'string') {
		opt = { url: opt }
	}
	var req = new XMLHttpRequest()
	req.onerror = function(e) {
		console.log('XMLHttpRequest.onerror', e.status, e.statusText, e.message, e)
	}
	req.onreadystatechange = function() {
		if (req.readyState === XMLHttpRequest.DONE) { // https://xhr.spec.whatwg.org/#dom-xmlhttprequest-done
			if (200 <= req.status && req.status < 400) {
				callback(null, req.responseText, req)
			} else {
				if (req.status === 0) {
					console.log('HTTP 0 Headers: \n' + req.getAllResponseHeaders())
				}
				var msg = "HTTP Error " + req.status + ": " + req.statusText
				callback(msg, req.responseText, req)
			}
		}
	}
	req.open(opt.method || "GET", opt.url, true)
	if (opt.headers) {
		for (var key in opt.headers) {
			req.setRequestHeader(key, opt.headers[key])
		}
	}
	req.send(opt.data)
}


function post(opt, callback) {
	if (typeof opt === 'string') {
		opt = { url: opt }
	}
	opt.method = 'POST'
	opt.headers = opt.headers || {}
	opt.headers['Content-Type'] = 'application/x-www-form-urlencoded'
	if (opt.data) {
		var s = '';
		for (var key in opt.data) {
			s += encodeURIComponent(key) + '=' + encodeURIComponent(opt.data[key]) + '&'
		}
		opt.data = s
	}
	request(opt, callback)
}


function getJSON(opt, callback) {
	request(opt, function(err, data, req) {
		if (!err && data) {
			data = JSON.parse(data)
		}
		callback(err, data, req)
	});
}


function postJSON(opt, callback) {
	if (typeof opt === 'string') {
		opt = { url: opt }
	}
	opt.method = opt.method || 'POST'
	opt.headers = opt.headers || {}
	opt.headers['Content-Type'] = 'application/json'
	if (opt.data) {
		opt.data = JSON.stringify(opt.data)
	}
	getJSON(opt, callback)
}

function getFile(url, callback) {
	var req = new XMLHttpRequest()
	req.onerror = function(e) {
		console.log('XMLHttpRequest.onerror', e.status, e.statusText, e.message, e)
	}
	req.onreadystatechange = function() {
		if (req.readyState === 4) {
			// Since the file is local, it will have HTTP 0 Unsent.
			callback(null, req.responseText, req)
		}
	}
	req.open("GET", url, true)
	req.send()
}

function parseMetadata(data) {
	var lines = data.split('\n')
	var d = {}
	for (var i = 0; i < lines.length; i++) {
		var line = lines[i]
		var delimeterIndex = line.indexOf('=')
		if (delimeterIndex >= 0) {
			var key = line.substr(0, delimeterIndex)
			var value = line.substr(delimeterIndex + 1)
			d[key] = value
		}
	}
	return d
}

function getAppletMetadata(callback) {
	var url = Qt.resolvedUrl('.')

	var s = '/share/plasma/plasmoids/'
	var index = url.indexOf(s)
	if (index >= 0) {
		var a = index + s.length
		var b = url.indexOf('/', a)
		// var packageName = url.substr(a, b-a);
		var metadataUrl = url.substr(0, b) + '/metadata.desktop'
		Requests.getFile(metadataUrl, function(err, data) {
			if (err) {
				return callback(err)
			}

			var metadata = parseMetadata(data)
			callback(null, metadata)
		});
	} else {
		return callback('Could not parse version.')
	}
}

function getAppletVersion(callback) {
	getAppletMetadata(function(err, metadata) {
		if (err) return callback(err)

		callback(err, metadata['X-KDE-PluginInfo-Version'])
	});
}
