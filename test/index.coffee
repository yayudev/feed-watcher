chai           = require 'chai'
sinon          = require 'sinon'
sinonChai      = require 'sinon-chai'
chaiAsPromised = require 'chai-as-promised'
Watcher        = require '../src/index'
expect         = chai.expect

chai.use chaiAsPromised
chai.use sinonChai
sampleFeed  = 'http://lorem-rss.herokuapp.com/feed?unit=second&interval=1'


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

  it 'should fullfill the promise on success', ->
    expect(fullfilledPromise).to.be.fullfilled

  it 'should return an array on success', (done) ->
    fullfilledPromise.then (entries) ->
      expect(entries).to.be.instanceOf Array
      done()

  it 'should return rss entries', (done) ->
    fullfilledPromise.then (entries) ->
      expect(entries[0]).to.have.property 'pubDate'
      expect(entries[0]).to.have.property 'title'
      expect(entries[0]).to.have.property 'link'
      done()

  it 'should return 10 items from feed', (done) ->
    fullfilledPromise.then (entries) ->
      expect(entries).to.have.length 10
      done()



describe 'start method', ->
  watcher = null
  fullfilledPromise = null
  rejectedPromise = null

  beforeEach ->
    watcher    = new Watcher(sampleFeed, 1)
    badWatcher = new Watcher(123123)

    fullfilledPromise = watcher.start()
    rejectedPromise   = badWatcher.start()
    rejectedPromise.catch (e) -> # Avoid errors display on test running

  it 'should be a Watcher function', ->
    expect(watcher).to.respondTo 'start'

  it 'should reject the promise on error', ->
    expect(rejectedPromise).to.be.rejected

  it 'should fullfill the promise on success', ->
    expect(fullfilledPromise).to.be.fullfilled

  it 'should update the lastEntryDate property on watcher', ->
    fullfilledPromise.then ->
      expect(watcher.lastEntryDate).to.not.equal null

  it 'should update the timer property on watcher', ->
    fullfilledPromise.then ->
      expect(watcher.timer).to.not.equal null

  it 'should return an array on success', (done) ->
    fullfilledPromise.then (entries) ->
      expect(entries).to.be.instanceOf Array
      done()

  it 'should return rss entries', (done) ->
    fullfilledPromise.then (entries) ->
      expect(entries[0]).to.have.property 'pubDate'
      expect(entries[0]).to.have.property 'title'
      expect(entries[0]).to.have.property 'link'
      done()

  it 'should return 10 items from feed', (done) ->
    fullfilledPromise.then (entries) ->
      expect(entries).to.have.length 10
      done()



describe 'stop method', ->
  watcher = null

  beforeEach ->
    watcher = new Watcher(sampleFeed, 1)

  it 'should be a Watcher function', ->
    expect(watcher).to.respondTo 'stop'

  it 'should remove the interval from the timer property on watcher', (done) ->
    watcher.start().then ->
      watcher.stop()
      expect(watcher.timer._idleTimeout).to.not.equal 1000
      done()

  it 'should emit a stop event', (done) ->
    watcher.on 'stop', done

    watcher.start().then -> watcher.stop()



describe 'On new entry event', ->
  @timeout 3000
  watcher = null

  beforeEach ->
    watcher = new Watcher(sampleFeed, .2)

  it 'should be called at least one time', (done) ->
    watcher.start()
    watcher.on 'new entries', ->
      watcher.stop()
      done()

  it 'should be called at least twice', (done) ->
    cb = sinon.spy()

    watcher.start()
    watcher.on 'new entries', -> cb()

    setTimeout ->
      watcher.stop()
      expect(cb.callCount).to.be.above 1
      done()
    , 2000


  it 'should recieve only one entry on second event trigger', (done) ->
    cb = sinon.spy()

    watcher.on 'new entries', (entries) -> cb(entries)
    watcher.start()

    setTimeout ->
      watcher.stop()
      lastCall = cb.lastCall.args[0]
      expect(lastCall).to.have.length 1
      done()
    , 2000

  it 'should return an array', (done) ->
    watcher.start()
    watcher.on 'new entries', (entries) ->
      watcher.stop()
      expect(entries).to.be.instanceOf Array
      done()

  it 'should return rss entries', (done) ->
    watcher.start()
    watcher.on 'new entries', (entries) ->
      watcher.stop()
      expect(entries[0]).to.have.property 'pubDate'
      expect(entries[0]).to.have.property 'title'
      expect(entries[0]).to.have.property 'link'
      done()

  it 'should return 10 items from feed', (done) ->
    watcher.start()
    watcher.on 'new entries', (entries) ->
      watcher.stop()
      expect(entries).to.have.length.above 8
      done()
