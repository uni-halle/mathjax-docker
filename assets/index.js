#!/usr/bin/env node

console.log('Node.JS running.');

( function () {
	'use strict';
	var penv = process.env;
	var server = require('./node_modules/mathjax-server/index.js');

	console.log("[node.js] Server starting on port " + penv.MATHJAX_PORT);
	server.start(penv.MATHJAX_PORT);
} () );

