(doc) ->
  if doc.nome and doc.cidade and not doc.inativo
    emit doc._id,
      rev: doc._rev
      attachments: doc._attachments
