(head, req) ->
  provides('text', ->
    send '<?xml version="1.0" encoding="UTF-8"?>'
    send '<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">'

    while row = getRow()
      send '<url><loc>http://doulas.club/doula/' + row.id + '</loc></url>'

    send '</urlset>'
  )
