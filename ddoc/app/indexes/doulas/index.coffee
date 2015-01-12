(doc) ->
  boost = (if doc.foto then 2 else 1) + (if doc.iframe then 2 else 1)

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

  if doc.outras_formacoes
    if typeof doc.outras_formacoes == 'object'
      formacoes = doc.outras_formacoes.join ' '
    else
      formacoes = doc.outras_formacoes

    index 'formacoes', formacoes

  if doc.coords
    index 'lat', doc.coords.lat
    index 'lng', doc.coords.lng

  index 'random', Math.random()
