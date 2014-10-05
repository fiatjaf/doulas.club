urlPattern = require 'url-pattern'

module.exports = (handlers) ->
  routes = []
  for args in handlers
    routes.push {
      pattern: urlPattern.newPattern args[0]
      handler: args.slice(-1)[0]
      fetchers: args.slice 1, -1
    }

  return {
    match: (path, cb) ->
      for r in routes
        params = r.pattern.match path
        if params
          if typeof window isnt 'undefined' and window._data
            # the '_data' variable is the one passed
            # manually by the server.
            cb null, r.handler, window._data
            delete window._data

          else
            waterfall r.fetchers, ((err, data) ->
              cb null, r.handler, data
            ), params

          return

      # no match
      cb {Error: 'no match.'}
    
    matchWithData: (path, data, cb) ->
      for r in routes
        params = r.pattern.match path
        if params
          cb null, r.handler, data

      # no match
      cb {Error: 'no match.'}
  }

waterfall = (tasks, cb, params) ->
  current = 0
  cb = cb or ->

  done = (err) ->
    args = Array::slice.call(arguments, 1)
    return cb(err, args) if err

    if ++current >= tasks.length
      cb.apply undefined, [null].concat args
    else
      tasks[current].apply undefined, args.concat(done)

  if tasks[current]
    tasks[current].apply undefined, [params].concat(done)
  else
    cb null, {}
