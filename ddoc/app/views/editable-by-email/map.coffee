(doc) ->
  get_emails = (emails) ->
    return ([].concat emails).filter((x) -> x)

  if doc.nome and doc.cidade # actual doc
    for email in get_emails doc.email
      emit [email, 1] # goes last in the index, so we only grab it if there is no draft
  else if doc.draft # draft doc
    for email in get_emails doc.draft.email
      emit [email, 0]
