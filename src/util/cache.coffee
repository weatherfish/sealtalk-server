LRU     = require "lru-cache"
Config  = require '../conf'
Utility = require('./util').Utility

class Cache
  @cache = LRU
    max: 100000
    maxAge: 3600000 # 3600000 ms = 1000 * 60 * 60 ms = 1 hour

  @set: (key, value) ->
    Utility.log "Cache: set '%s'.", key
    Promise.resolve @cache.set(key, value)

  @get: (key) ->
    Utility.log "Cache: get '%s'.", key
    Promise.resolve @cache.get(key)

  @del: (key) ->
    Utility.log "Cache: del '%s'.", key
    Promise.resolve @cache.del(key)

module.exports = Cache
