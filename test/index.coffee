chai           = require 'chai'
chaiAsPromised = require 'chai-as-promised'
Watcher        = require '../src/index'
expect         = chai.expect

chai.use(chaiAsPromised)

sampleFeed = 'http://lorem-rss.herokuapp.com/feed?unit=second&interval=10'


describe 'Watcher class', ->
  it 'should be instantiable', ->
    watcher = new Watcher(sampleFeed)
    expect(watcher).to.not.be.undefined


  it 'should raise an error if url wasn\'t defined', ->
    fn = -> watcher = new Watcher()
    expect(fn).to.throw 'feedUrl isn\'t defined'



describe 'config method', ->
  watcher = null

  beforeEach ->
    watcher = new Watcher(sampleFeed)
    watcher.config {feedUrl:'https://modifiedFeed.something', interval: 100}

  it 'should be a Watcher function', ->
    expect(watcher).to.respondTo 'config'

  it 'should save and overwrite options', ->
    expect(watcher.feedUrl).to.equal 'https://modifiedFeed.something'
    expect(watcher.interval).to.equal 100



describe 'checkAll method', ->
  watcher = null
  fullfilledPromise = null
  rejectedPromise = null

  beforeEach ->
    watcher    = new Watcher(sampleFeed)
    badWatcher = new Watcher(123123)

    fullfilledPromise = watcher.checkAll()
    rejectedPromise   = badWatcher.checkAll()
    rejectedPromise.catch (e) -> # Avoid errors display on test running


  it 'should be a Watcher function', ->
    expect(watcher).to.respondTo 'checkAll'

  it 'should reject the promise on error', ->
    expect(rejectedPromise).to.be.rejected

  it 'should not fullfill the promise on error', ->
    expect(rejectedPromise).to.not.be.fullfilled

  it 'should fullfill the promise on success', ->
    expect(fullfilledPromise).to.be.fullfilled

  it 'should not reject the promise on success', ->
    expect(fullfilledPromise).to.not.be.rejected

  it 'should return an array on success', (done) ->
    fullfilledPromise.then (entries) ->
      expect(entries).to.be.instanceOf(Array)
      done()



# describe 'start method', ->

