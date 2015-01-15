(doc, req) ->
  if doc
    return require('main')('doula-page', doc, req)
  else
    return require('main')('results-page', {}, req)
