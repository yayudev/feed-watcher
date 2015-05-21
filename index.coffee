{EventEmitter} = require 'events'
parser         = require 'parse-rss'
Promise        = require 'bluebird'


class Watcher extends EventEmitter
  constructor: (feedUrl, interval) ->
    throw new Error 'feedUrl isn\'t defined' if not feedUrl?

    @feedUrl        = feedUrl
    @interval       = interval or 60   # 1 hour by default
    @lastEntryDate  = null # Used to make sure if there is new entries.
    @lastEntryTitle = null # Used to avoid duplicates.
    @timer          = null # Stores watcher function.

    @watch = =>
      # Check feed.
      fetch = =>
        request @feedUrl, (err, entries) =>
          return @emit 'error', err if err?

          console.log ('Checking...')
          # Check for new entries
          newEntries = []
          for entry in entries
            if @lastEntryDate is null or @lastEntryDate < entry.pubDate/1000
              newEntries.push entry

          console.log newEntries.length
          console.log newEntries[0].pubDate
          # Update if new entries
          # It uses newEntries[0] as last entry because they are
          # ordered from newest to oldest.
          if newEntries.length > 0
            @lastEntryDate  = newEntries[0].pubDate/1000
            @lastEntryTitle = newEntries[0].title
            @emit 'new entries', newEntries

      # Keep checking every n minutes.
      # It returns the timer so it can be cleared after.
      return setInterval =>
        fetch(@feedUrl)
      , @interval*1000


  # Check all entries on the feed.
  checkAll: ->
    new Promise (resolve, reject) =>
      request @feedUrl, (err, entries) =>
        return reject err if err?
        return resolve entries


  # Set up the watcher.
  config: (cfg) ->
    @feedUrl  = cfg.feedUrl  if cfg.feedUrl?
    @interval = cfg.interval if cfg.interval?


  # Start watching.
  start: ->
    new Promise (resolve, reject) =>
      request @feedUrl, (err, entries) =>
        return resolve err if err?

        @lastEntryDate = entries[entries.length-1].pubDate/1000
        @timer = @watch()
        return resolve entries

  # Stop watching.
  stop: ->
    clearInterval @timer
    @emit 'stop'



request = (feedUrl, callback) ->
  parser feedUrl, (err, entries) =>
    return callback err, null if err?

    #sort the entries by release
    entries.sort (a, b)->
      return b.pubDate/1000 - a.pubDate/1000

    return callback null, entries



module.exports = Watcher
