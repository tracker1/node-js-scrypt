var argScrubber = require('./argument-scrubber');
var fork = require('child_process').fork;
var gp = require('generic-pool');
var cpu_count = require('os').cpus().length;

//let there be up to cpu_count - 1 workers
var max_workers = cpu_count - 1;
var pool = pool = new gp.Pool({
	name: 'scrypt-worker'
	,create: function(callback) {
		var worker = fork(__dirname + '/scrypt-async-worker.js',{execArgv:[]});
		worker.controlledExit = false;
		worker.on('exit',function(){
			if (!worker.controlledExit) {
				setImmediate(pool.destroy.bind(pool,worker));
			}
		});
		callback(worker);
	}
	,destroy: function(worker) {
		//console.log('destroy-worker')
		try {
			//disconnect RPC channel
			worker.controlledExit = true;
			worker.disconnect(); 
		} catch(err) {}
	}
	,max: Math.max(2, cpu_count-1)
	,min:0
	,idleTimeoutMillis: 15000 //15 seconds
	,log:false
});

module.exports = function scryptAsync(password, salt, options, callback) {
	var args = argScrubber.apply(null,arguments);
	var cb = args.callback || function(){}; //local ref to callback
	
	delete args.callback; //don't pass to child
	args.password = args.password.toString('base64');
	args.salt = args.salt.toString('base64');

	var start = new Date();

	pool.acquire(function(err,worker){
		//console.log("got worker");

		if (err) {
			pool.release(worker);
			return cb(err);
		}

		worker.once('message', function(response) {
			var end = new Date();
			//console.log("processed", end - start);
			//console.log("got message from worker: " + response);

			pool.release(worker); //done with child process
			if (response.error) cb(response.error); //return error
			cb(null, new Buffer(response.data, 'base64')); //return data
		});

		worker.send(args);
	});
};
