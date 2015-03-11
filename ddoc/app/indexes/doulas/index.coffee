(doc) ->
  if not doc.cidade or doc.inativo
    return

  boost =
    (if doc.foto then 2 else 1) +
    (if doc.iframe then 1.9 else 1) +
    (if doc.site then 1.5 else 1) +
    (if doc.tel then 1.4 else 1) +
    (if doc.email then 1.4 else 1) +
    (if doc.intro then 2 else 1) +
    (25 - 'abcdefghijklmnopqrstuvwxyz'.indexOf(doc.nome[0].toLowerCase()))/100

  index(
    'default'
    doc.nome + ' ' + doc.cidade + ' ' + (doc.intro or '') + ' ' + (doc.formacao or '')
    {boost: boost}
  )

  index 'boost', boost

  index 'cidade', doc.cidade
  index 'nome', doc.nome
  index 'foto', if doc.foto then true else false

  if doc.formacao
    index 'formacao', doc.formacao

  if doc.desde
    index 'desde', doc.desde

  if typeof doc.email == 'string'
    index 'email', doc.email
  else if typeof doc.email == 'object'
    index 'email', doc.email.join ' '

  if typeof doc.outras_formacoes == 'string'
    formacoes = doc.outras_formacoes.join ' '
  else if typeof doc.outras_formacoes == 'object'
    formacoes = doc.outras_formacoes

    index 'formacoes', formacoes

  if doc.coords
    index 'lat', doc.coords.lat
    index 'lng', doc.coords.lng

  index 'random', Math.random()
