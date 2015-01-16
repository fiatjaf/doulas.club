(doc, req) ->
  redirect = (url) ->
    code: 302
    headers:
      Location: url

  path = req.path.slice 5

  if doc
    return require('main')('doula-page', doc, req)
  else
    if path.length == 1 and path[0] == 'search' and req.query.q
      return require('main')('results-page', {}, req)
    else if path.length == 0 and not req.query.q
      return require('main')('results-page', {}, req)
    else if req.query.q
      return redirect '/search?q=' + req.query.q
    else
      return redirect '/'
