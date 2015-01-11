urlPattern = require 'lib/url-pattern'
url = require 'lib/url'
qs = require 'lib/querystring/index'

module.exports = (handlers) ->
  routes = []
  for args in handlers
    # - pattern is the url pattern that will match, along with its variables,
    # like /something/:variable.
    # - handler is the function that will be called with the final data in the
    # end (the final data can be nothing, and will be nothing if there are no
    # fetchers)
    # - fetchers are the functions that will be called asynchronously, one after
    # one, and receiving the values fetched by the previous one, in a waterfall
    # pattern. it will receive a callback as its last argument and values as the
    # first ones.
    #
    # example:
    # 1st fetcher will receive (paramsFromURL, paramsFromQuery, arbitraryData, callback)
    # 2nd fetcher will receive (arg1, arg2, callback)
    #     if the first called callback(null, arg1, arg2)

    routes.push {
      pattern: urlPattern.newPattern args[0]
      handler: args.slice(-1)[0]
      fetchers: args.slice 1, -1
    }

  match = (url, arbitraryData, cb) ->
    # url can be either a full url, a pathname or an express req object,
    # parseURL will handle these cases and return the correct things.

    # arbitraryData is useful for getting data from the server, such as
    # raw request data and stuff alike, but it is totally optional
    if not cb
      cb = arbitraryData

    {querystring, pathname} = parseURL url

    for r in routes
      params = r.pattern.match pathname
      if params
        if typeof window isnt 'undefined' and typeof window._data isnt 'undefined'
          # the '_data' variable is the one passed
          # manually by the server.
          cb null, r.handler, window._data
          delete window._data

        else
          args = [r.fetchers, ((err, data) ->
            cb null, r.handler, data
          ), params]
          if r.fetchers and r.fetchers[0]
            if r.fetchers[0].length > 2
              args.push querystring
            if r.fetchers[0].length > 3
              args.push arbitraryData
          waterfall.apply @, args
        return
    # no match
    cb {Error: 'no match.'}

  matchWithData = (url, data, cb) ->
    # matchWithData ignores fetchers and querystring and just applies
    # the given data to the previously registered handler at given
    # path/url.

    {pathname} = parseURL url

    for r in routes
      params = r.pattern.match pathname
      if params
        cb null, r.handler, data
    # no match
    cb {Error: 'no match.'}

  parseURL = (something) ->
    # this can get either an express request object
    # or a raw href or even a raw pathname with or without querystring
    # it returns an object with {pathname: '...', querystring: {}}
    if typeof something is 'object' and something.url
      req = something
      return {pathname: url.parse(req.url).pathname, querystring: req.query}
    else if typeof something is 'string'
      url = url.parse(something)
      return {pathname: url.pathname, querystring: qs.parse(url.search)}
    else
      throw {Error: 'Invalid url or pathname passed to agnostic-router.'}

  return {
    match: match
    matchWithData: matchWithData
  }

waterfall = (tasks, cb) ->
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
    args = Array::slice.call(arguments, 2) # all parameters after the callback
    tasks[current].apply undefined, args.concat(done)
  else
    cb null, {}
