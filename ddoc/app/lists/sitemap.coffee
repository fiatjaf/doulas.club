(head, req) ->
  start
    headers: 'Content-Type': 'text/xml'

  send '<?xml version="1.0" encoding="UTF-8"?>'
  send '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">'

  places = ["São Paulo", "Rio de Janeiro", "Salvador", "Brasília", "Fortaleza", "Belo Horizonte", "Manaus", "Curitiba", "Recife", "Porto Alegre", "Belém", "Goiânia", "Guarulhos", "Campinas", "São Luís", "São Gonçalo", "Maceió", "Duque de Caxias", "Natal", "Campo Grande", "Teresina", "João Pessoa", "Santo André", "Osasco", "São José dos Campos", "Ribeirão Preto", "Uberlândia"]
  for place in places
    q = place.replace /\s/g, '+'
    url = "http://doulas.club/doulas/em/#{q}/"
    send "<url><loc>#{url}</loc></url>"

  while row = getRow()
    send '<url><loc>http://doulas.club/' + row.id + '</loc></url>'

  send '</urlset>'
