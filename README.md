# rss-feed-watcher
rss-feed-watcher is a rss watcher based on <a href="https://github.com/nikezono/node-rss-watcher" target="_blank">Nikenozo's rss-watcher</a> but optimized for synchronous data handling and storing with the results from the parse. Also it was rewritted for using promises as a response to requests instead of callbacks for better code quality :)

## Installation
You can install rss-feed-watcher by using:
```
  git clone git@github.com:datyayu/rss-feed-watcher.git # npm comming soon TM
  npm install
```

## Usage
A basic watcher can be created using:
```
  Watcher  = require './rss-feed-watcher'
  feed     = 'http://github.com/datyayu.atom'
  interval = 10 #seconds

  # if not interval is passed, 60s would be setted as default interval.
  watcher = new Watcher(feed, interval)

  # Check for new entries every n seconds.
  watcher.on 'new entries', (entries) ->
    for entry in entries
      console.log entry.title

  # Start watching the feed.
  watcher.start()
    .then (entries) ->
      console.log entries
    .catch (err) ->
      console.log 'ups, it broke'

  # Stop watching the feed.
  watcher.stop()
```

### Options
If you want to change the watcher config after creating it, you should use watcher.config:
```
  watcher.config
    feedUrl: feed # feed url
    interval: 60  # Interval between requests in seconds.
```

### Events
Watcher exposes 3 events: 'new entries', 'stop' and 'error'.
```
  # Returns an array of entry objects founded since last check.
  watcher.on "new entries", (entries) ->
    console.log entries

  # Emitted when watchet.stop() is called,
  watcher.on "stop", ->
    console.log 'stop'

  # Emitted when an error ocurred at checking feed.
  watcher.on "error", (error) ->
    console.error error
```

## Tests
Tests can be run using ```npm test```.*

Note: tests still have some problems with chai's done() being called twice after first consecutive run, so wait a couple of seconds if you want to rerun them.
