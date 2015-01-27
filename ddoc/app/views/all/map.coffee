(doc) ->
  if doc.nome and doc.cidade
    emit doc._rev
