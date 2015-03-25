(doc, req) ->
  redirect = (url, code=302) ->
    code: code
    headers:
      Location: url

  path = req.path.slice 5

  if doc
    if doc.inativo
      return {code: 404, body: 'Esta doula não existe, não atua mais como doula ou pediu para ser removida de nosso diretório.'}
    else if doc.redirect
      return redirect '/' + doc.redirect, 301
    else
      return require('main')('doula-page', doc, req)
  else
    if path.length == 1 and path[0] == 'search' and req.query.q
      return require('main')('results-page', {}, req)
    else if path.length == 0 and not req.query.q
      return require('main')('results-page', {}, req)
    else if 'q' of req.query
      return redirect '/search?q=' + req.query.q
    else
      return redirect '/'
