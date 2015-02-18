(doc) ->
  if doc.draft
    emit doc['last-edited']
