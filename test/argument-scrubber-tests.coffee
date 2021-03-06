should = require('chai').should()
scrubber = require '../lib/argument-scrubber.js'

# values for "test ??????"
binaryString = '\x74\x65\x73\x74\x20\xe1\x83\x95\xe1\x83\x94\xe1\x83\x9e\xe1\x83\xae\xe1\x83\x98\xe1\x83\xa1'
utf8Buffer = new Buffer(binaryString, 'binary')
utfString = utf8Buffer.toString('utf8');


describe "password and salt argument handling", ->
  it "Should use password as first argument, then salt as second", ->
    data = scrubber("a","b")
    data.password[0].should.equal 0x61
    data.salt[0].should.equal 0x62
  it "Accepts Buffer as-is", ->
    data = scrubber(utf8Buffer, utf8Buffer)
    data.password.should.be.an.instanceof(Buffer).and.deep.equal utf8Buffer
    data.salt.should.be.an.instanceof(Buffer).and.deep.equal utf8Buffer
  it "Encodes string as a UTF8 encoded Buffer", ->
    data = scrubber(utfString,utfString)
    data.password.should.be.an.instanceof(Buffer).and.deep.equal utf8Buffer
    data.salt.should.be.an.instanceof(Buffer).and.deep.equal utf8Buffer
  it "Coerces non-string falsy values to empty string", ->
    data = scrubber()
    data.password.should.be.an.instanceof(Buffer).and.deep.equal new Buffer("")
    data.salt.should.be.an.instanceof(Buffer).and.deep.equal new Buffer("")


describe "options argument", ->
  it "Returns default options when not specified", ->
    data = scrubber()
    data.options.should.be.a("Object")
    data.options.maxmem.should.be.a("Number").and.equal (32 * 1024 * 1024) #32mb
    data.options.cost.should.be.a("Number").and.equal Math.pow(2,14);
    data.options.blockSize.should.be.a("Number").and.equal 8
    data.options.parallel.should.be.a("Number").and.equal 1
    data.options.size.should.be.a("Number").and.equal 64


describe "options.cost argument", ->
  it "Returns default when not a number", ->
  	data = scrubber(null,null,{cost:''})
  	data.options.cost.should.be.a("Number").and.equal Math.pow(2,14)
  it "Returns default when <Math.pow(2,8)", ->
  	data = scrubber(null,null,{cost:0})
  	data.options.cost.should.be.a("Number").and.equal Math.pow(2,14)
  it "Returns default when >Math.pow(2,64)", ->
  	data = scrubber(null,null,{cost:Math.pow(2,65)})
  	data.options.cost.should.be.a("Number").and.equal Math.pow(2,14)
  it "Returns default when not a power of 2", ->
  	data = scrubber(null,null,{cost:Math.pow(2,14)+1})
  	data.options.cost.should.be.a("Number").and.equal Math.pow(2,14)
  it "Accepts min value Math.pow(2,8)", ->
  	data = scrubber(null,null,{cost:Math.pow(2,8)})
  	data.options.cost.should.be.a("Number").and.equal Math.pow(2,8)
  it "Accepts max value Math.pow(2,64)", ->
  	data = scrubber(null,null,{cost:Math.pow(2,64)})
  	data.options.cost.should.be.a("Number").and.equal Math.pow(2,64)

describe "options.blockSize argument", ->
  it "Returns default when not a number", ->
  	data = scrubber(null,null,{blockSize:''})
  	data.options.blockSize.should.be.a("Number").and.equal 8
  it "Returns default when <1", ->
  	data = scrubber(null,null,{blockSize:0})
  	data.options.blockSize.should.be.a("Number").and.equal 8
  it "Returns default when >256", ->
  	data = scrubber(null,null,{blockSize:257})
  	data.options.blockSize.should.be.a("Number").and.equal 8
  it "Accepts min value 1", ->
  	data = scrubber(null,null,{blockSize:1})
  	data.options.blockSize.should.be.a("Number").and.equal 1
  it "Accepts max value 256", ->
  	data = scrubber(null,null,{blockSize:256})
  	data.options.blockSize.should.be.a("Number").and.equal 256

describe "options.parallel argument", ->
  it "Returns default when not a number", ->
    data = scrubber(null,null,{parallel:''})
    data.options.parallel.should.be.a("Number").and.equal 1
  it "Returns default when <1", ->
    data = scrubber(null,null,{parallel:0})
    data.options.parallel.should.be.a("Number").and.equal 1
  it "Returns default when >256", ->
    data = scrubber(null,null,{parallel:257})
    data.options.parallel.should.be.a("Number").and.equal 1
  it "Accepts min value 1", ->
    data = scrubber(null,null,{parallel:1})
    data.options.parallel.should.be.a("Number").and.equal 1
  it "Accepts max value 256", ->
    data = scrubber(null,null,{parallel:256})
    data.options.parallel.should.be.a("Number").and.equal 256

describe "options.size argument", ->
  it "Returns default when not a number", ->
    data = scrubber(null,null,{size:''})
    data.options.size.should.be.a("Number").and.equal 64
  it "Returns default when <1", ->
    data = scrubber(null,null,{size:0})
    data.options.size.should.be.a("Number").and.equal 64
  it "Returns default when >2048", ->
    data = scrubber(null,null,{size:2049})
    data.options.size.should.be.a("Number").and.equal 64
  it "Accepts min value 1", ->
    data = scrubber(null,null,{size:1})
    data.options.size.should.be.a("Number").and.equal 1
  it "Accepts max value 2048", ->
    data = scrubber(null,null,{size:2048})
    data.options.size.should.be.a("Number").and.equal 2048


describe "callback argument", ->
  fn = (->)
  it "Returns null when not a Function", ->
  	data = scrubber(null,null,null,"")
  	should.not.exist(data.callback)
  it "Returns the function when it is a function", ->
  	data = scrubber(null,null,null,fn)
  	data.callback.should.equal fn
  it "Returns the last argument when it is a function", ->
  	data = scrubber(fn)
  	data.callback.should.equal fn