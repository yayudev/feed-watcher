import {EventEmitter} from 'events';
import parser from 'parse-rss';

function request(feedUrl) {
  return new Promise((resolve, reject) => {
    parser(feedUrl, (error, entries) => {
      if (error) { return reject(error); }
      if (!entries) { return reject(new Error('No entries were founded. Check your url.')); }

      // Sort by release.
      entries.sort((ent1, ent2) => ((ent2.pubDate / 1000) - (ent1.pubDate / 1000)));
      resolve(entries);
    });
  });
}


class Watcher extends EventEmitter {
  constructor(feedUrl, interval) {
    super();

    // Make sure the url exists and it's a string.
    if (!feedUrl || typeof feedUrl !== 'string') {
      throw new Error('feedUrl isn\'t defined');
    }

    this.feedUrl = feedUrl;
    this.interval = interval || 60;  // 1 hour by default
    this.lastEntryDate = null; // Used to make sure if there is new entries.
    this.lastEntryTitle = null; // Used to avoid duplicates.
    this.timer = null; // Stores watcher function.
  }

  // Check all entries on the feed.
  checkAll() {
    return request(this.feedUrl);
  }

  // Set up the watcher.
  config(cfg) {
    this.feedUrl = cfg && cfg.feedUrl ? cfg.feedUrl : this.feedUrl;
    this.interval = cfg && cfg.interval ? cfg.interval : this.interval;
  }

  // Start watching.
  start() {
    return new Promise((resolve, reject) => {
      this.checkAll()
        .then((entries) => {
          this.lastEntryDate = entries[0].pubDate / 1000;
          this.lastEntryTitle = entries[0].title;
          this.timer = this.watch();
          resolve(entries);
        })
        .catch((err) => {
          reject(err);
        });
    });
  }

  // Stop watching.
  stop() {
    clearInterval(this.timer);
    this.emit('stop');
  }

  // Check the feed.
  watch() {
    const fetch = () => {
      this.checkAll()
        .then((entries) => {
          // Filter older entries.
          const newEntries = entries.filter((entry) => {
            return (this.lastEntryDate === null || this.lastEntryDate < (entry.pubDate / 1000));
          });

          // Update last entry.
          // It uses newEntries[0] because they are ordered from newer to older.
          if (newEntries.length > 0) {
            this.lastEntryDate = newEntries[0].pubDate / 1000;
            this.lastEntryTitle = newEntries[0].title;
            this.emit('new entries', newEntries);
          }
        })
        .catch(error => this.emit('error', error));
    };

    // Keep checking every n minutes.
    // It returns the timer so it can be cleared after.
    return setInterval(() => {
      fetch(this.feedUrl);
    }, this.interval * 1000);
  }
}

export default Watcher;
