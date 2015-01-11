(head, req) ->
  start
    headers: 'Content-Type': 'text/xml'

  send '<?xml version="1.0" encoding="UTF-8"?>'
  send '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">'

  while row = getRow()
    send '<url><loc>http://doulas.club/' + row.id + '</loc></url>'

  send '</urlset>'
