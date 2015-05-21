{expect} = require 'chai'
Watcher  = require '../index'

sampleFeed = 'https://github.com/datyayu.atom'



describe 'Watcher class', =>

  it 'should be defined', ->
    watcher = new Watcher(sampleFeed)
    expect(watcher).to.not.be.undefined


  it 'should raise an error if url wasn\'t defined', ->
    fn = -> watcher = new Watcher()
    expect(fn).to.throw 'feedUrl isn\'t defined'


describe 'config method', =>

  it 'should be a Watcher function', ->
    watcher = new Watcher(sampleFeed)
    expect(watcher).to.respondTo 'config'


  it 'should save and overwrite options', ->
    watcher = new Watcher(sampleFeed)
    watcher.config {feedUrl:'https://modifiedFeed.something', interval: 100}
    expect(watcher.feedUrl).to.equal 'https://modifiedFeed.something'
    expect(watcher.interval).to.equal 100
