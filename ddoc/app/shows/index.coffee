(doc, req) ->
  if doc
    return require('main')('doula-page', doc)
  else
    return require('main')('results-page', {})
