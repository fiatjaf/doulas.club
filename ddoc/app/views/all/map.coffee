(doc) ->
  if doc.nome and doc.cidade
    emit doc._id,
      rev: doc._rev
      attachments: doc._attachments
