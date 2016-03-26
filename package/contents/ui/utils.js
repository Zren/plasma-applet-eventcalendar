function request(opt, callback) {
    if (typeof opt === 'string') {
        opt = {url: opt};
    }
	var req = new XMLHttpRequest();
    req.onreadystatechange = function() {
        if (req.readyState === 4) {
            if (200 <= req.status && req.status < 400) {
                callback(null, req.responseText, req);
            } else {
                if (req.status === 0) {
                    console.log('HTTP 0 Headers: \n' + req.getAllResponseHeaders());
                }
                var msg = "HTTP Error " + req.status + ": " + req.statusText;
                callback(msg, req.responseText, req);
            }
        }
    }
    req.open(opt.method || "GET", opt.url, true);
    if (opt.headers) {
        for (var key in opt.headers) {
            req.setRequestHeader(key, opt.headers[key]);
        }
    }
    req.send(opt.data);
}


function post(opt, callback) {
    if (typeof opt === 'string') {
        opt = {url: opt};
    }
    opt.method = 'POST';
    opt.headers = opt.headers || {};
    opt.headers['Content-Type'] = 'application/x-www-form-urlencoded';
    if (opt.data) {
        var s = '';
        for (var key in opt.data) {
            s += encodeURIComponent(key) + '=' + encodeURIComponent(opt.data[key]) + '&';
        }
        opt.data = s;
    }
    request(opt, callback);
}


function getJSON(opt, callback) {
    request(opt, function(err, data, req) {
        if (!err && data) {
            data = JSON.parse(data);
        }
        callback(err, data, req);
    });
}


function postJSON(opt, callback) {
    if (typeof opt === 'string') {
        opt = {url: opt};
    }
    opt.method = 'POST';
    opt.headers = opt.headers || {};
    opt.headers['Content-Type'] = 'application/json';
    if (opt.data) {
        opt.data = JSON.stringify(opt.data);
    }
    getJSON(opt, callback);
}

