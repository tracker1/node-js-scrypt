module.exports = cleanInputArguments;

function cleanInputArguments(password, salt, options, callback) {
	return {
		password: cleanString(password),
		salt: cleanString(salt),
		options: cleanOptions(options),
		callback: cleanCallback(arguments[arguments.length - 1])
	};
}

function cleanString(input) {
	if (typeof input == 'function') return Buffer('', 'utf8');
	if (input instanceof Buffer) return input;
	if (typeof input == 'string') return new Buffer(input, 'utf8');
	return new Buffer(String(input || ''), 'utf8');
}

function cleanOptions(options) {
	//console.log('cleanOptions ', options, typeof options);
	options = (options !== null && typeof options === 'object') ? options : {}

	return {
		maxmem: checkMaxmem(options.maxmem) || (32 * 1024 * 1024),
		cost:  checkN(options.cost) || Math.pow(2,14),
		blockSize:  checkNumber(options.blockSize) || 8,
		parallel:  checkNumber(options.parallel) || 1,
		size:  checkLength(options.size) || 64
	};
}

function cleanCallback(callback) {
	if (typeof callback === 'function') return callback;
	return null;
}

function checkMaxmem(mem) {
	var mb = 1024 * 1024;
	if (typeof mem !== 'number') return null;
	for (var m = 4; m <= 2048; m = m * 2) {
		var checkVal = m * mb;
		if (checkVal > mem) return null;
		if (checkVal == mem) return checkVal;
	}
	return null;
}

function checkN(input) {
	//console.log('checkN ',input);
	if (typeof input !== 'number') return null;
	for (var m = 8; m <= 64; m++) {
		var checkVal = Math.pow(2,m);
		//console.log('checkVal ',input);
		if (checkVal > input) return null;
		if (checkVal == input) return checkVal;
	}
	return null;
}


function checkNumber(input) {
	if (typeof input !== 'number') return null;
	input = Math.round(input);
	if (input < 1) return null;
	if (input > 256) return null;
	return input;
}

function checkLength(input) {
	if (typeof input !== 'number') return null;
	input = Math.round(input);
	if (input < 1) return null;
	if (input > 2048) return null;
	return input;
}