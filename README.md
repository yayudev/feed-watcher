# feed-watcher
[![npm version](https://badge.fury.io/js/feed-watcher.svg)](http://badge.fury.io/js/feed-watcher) </br>
feed-watcher is a rss watcher based on <a href="https://github.com/nikezono/node-rss-watcher" target="_blank">Nikenozo's rss-watcher</a> but optimized for synchronous data handling and storing of the results from the parse. Also it was rewritted to use promises as on not-event-based requests instead of callbacks for better code quality :)

## Installation
You can install feed-watcher by using:
```
  npm install feed-watcher
```

## Usage
A basic watcher can be created using:
```
  var Watcher  = require('feed-watcher'),
      feed     = 'http://lorem-rss.herokuapp.com/feed?unit=second&interval=5',
      interval = 10 // seconds

  // if not interval is passed, 60s would be set as default interval.
  var watcher = new Watcher(feed, interval)

  // Check for new entries every n seconds.
  watcher.on('new entries', function (entries) {
    entries.forEach(function (entry) {
      console.log(entry.title)
    })
  })

  // Start watching the feed.
  watcher
    .start()
    .then(function (entries) {
      console.log(entries)
    })
    .catch(function(error) {
      console.error(error)
    })

  // Stop watching the feed.
  watcher.stop()
```

### Options
If you want to change the watcher config after creating it, you should use watcher.config:
```
  watcher.config({ feedUrl: feed, interval: 60 })
```

### Events
Watcher exposes 3 events: 'new entries', 'stop' and 'error'.
```
  // Returns an array of entry objects founded since last check.
  watcher.on('new entries', function (entries) {
    console.log(entries)
  })

  // Emitted when watcher.stop() is called,
  watcher.on('stop', function () {
    console.log('stopped')
  })

  // Emitted when an error happens while checking feed.
  watcher.on('error', function (error) {
    console.error(error)
  })
```

## Tests
Tests can be run using
```
  npm test
```

## License
Project License can be found <a href="https://github.com/datyayu/feed-watcher/blob/master/LICENSE.md">here</a>
