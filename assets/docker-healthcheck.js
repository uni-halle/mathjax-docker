#!/usr/bin/env node

(function() {
	'use strict';
	const penv = process.env;
	const host = 'localhost';
	const port = penv.MATHJAX_PORT;

	function req(format) {
		const http = require('http');
		const pdata = {
			"format": "TeX",
			"math": "b + y = \\sqrt{f} = \\sum_n^5 {x}",
			"svg": (format === 'svg'),
			"mml": false,
			"png": (format === 'png'),
			"speakText": false,
			"speakRuleset": "mathspeak",
			"speakStyle": "default",
			"ex": 6,
			"width": 100,
			"linebreaks": false,
		};

		const datastring = JSON.stringify(pdata);

		const options = {
			'hostname': host,
			'port': port,
			'path': '/',
			'method': 'POST',
			'headers': {
				'Content-Type': 'application/json',
				'Content-Length': datastring.length
			}
		};

		const request = http.request(options, function(response) {
			var body = '';

			response.on('data', function(data) {
				body += data;
			});
			response.on('end', function() {
				if (format === 'png' && body.indexOf('IHDR') === -1) {
					console.error('[healthcheck] unexpected response ' + body);
					process.exit(1);
				} else if (format === 'svg' && body.indexOf('<svg') === -1) {
					console.error('[healthcheck] unexpected response ' + body);
					process.exit(1);
				}
				//console.log('[healthcheck] ' + body);
			});
		});

		request.on('error', function(e) {
			console.error('[healthcheck] problem with request: ' + e.message);
			process.exit(1);
		});

		console.info('[healthcheck] Sending request to ' + host + ':' + port);
		request.write(datastring);
		request.end();
	}

	req('svg');
	req('png');
}());

