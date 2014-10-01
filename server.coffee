path = require 'path'
url = require 'url'
express = require 'express'
superagent = require 'superagent'
React = require 'react'
ReactAsync = require 'react-async'
App = require './client.coffee'

renderApp = (req, res, next) ->
  path = url.parse(req.url).pathname
  data =
    path: path

  ReactAsync.renderComponentToStringWithAsyncState App(data), (err, markup) ->
    return next err if err
    res.send "<!doctype html>\n" + markup

api = express()
  .get('/doulas', (req, res, next) ->
    search = superagent.get(process.env.COUCH_URL + '/_design/app/_search/doulas')
    search.query(include_docs: 'true')
    search.query(limit: 30)

    if req.query.near
      latlng = req.query.near.split(',')
      lat = latlng[0]
      lng = latlng[1]
      search.query(sort: "<distance,lng,lat,#{lng},#{lat},km>")

    if req.query.bookmark
      search.query(bookmark: bookmark)

    q = req.query.q or '*'
    search.query(q: q)

    search.end (err, r) ->
      return next() if err
      res.set 'content-type', 'application/json'
      res.send r.body
  )
  .get('/doula/:id', (req, res, next) ->
    superagent.get process.env.COUCH_URL + '/' + req.params.id, (err, r) ->
      return next() if err
      res.set 'content-type', 'application/json'
      res.send r.text
  )
  

app = express()
app.use("/assets", express.static(path.join(__dirname, "assets")))
   .use("/api", api)
   .use(renderApp)
   .listen process.env.PORT or 3000, ->
  console.log 'started!'
