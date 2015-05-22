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
        request @feedUrl
          .then (entries) =>
            # Check for new entries
            newEntries = []
            for entry in entries
              if @lastEntryDate is null or @lastEntryDate < entry.pubDate/1000
                newEntries.push entry

            # Update if new entries.
            # It uses newEntries[0] as last entry because they are
            # ordered from newest to oldest.
            if newEntries.length > 0
              @lastEntryDate  = newEntries[0].pubDate/1000
              @lastEntryTitle = newEntries[0].title
              @emit 'new entries', newEntries

          .catch (error) =>
            @emit 'error', error

      # Keep checking every n minutes.
      # It returns the timer so it can be cleared after.
      return setInterval =>
        fetch(@feedUrl)
      , @interval*1000


  # Check all entries on the feed.
  checkAll: ->
    new Promise (resolve, reject) =>
      request @feedUrl
        .then (entries) ->
          resolve entries

        .catch (err) ->
          reject err


  # Set up the watcher.
  config: (cfg) ->
    @feedUrl  = cfg.feedUrl  if cfg.feedUrl?
    @interval = cfg.interval if cfg.interval?


  # Start watching.
  start: ->
    new Promise (resolve, reject) =>
      request @feedUrl
        .then (entries) =>
          @lastEntryDate = entries[0].pubDate/1000
          @timer = @watch()
          resolve entries

        .catch (err) ->
          reject err


  # Stop watching.
  stop: ->
    clearInterval @timer
    @emit 'stop'



request = (feedUrl) ->
  new Promise (resolve, reject) ->
    parser feedUrl, (err, entries) ->
      throw new Error(err) if err?

      entries.sort (a, b) -> (b.pubDate/1000 - a.pubDate/1000) # Sort by release.
      resolve entries



module.exports = Watcher
