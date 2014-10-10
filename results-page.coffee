React = require 'react'
marked = require 'marked'

{html, body, meta, script, link, title,
 div, iframe, ul, li, header, article,
 span, a, h1, h2, h3, h4, img,
 form, input, button} = React.DOM

superagent = require 'superagent'
{Link} = require './react-router'

localStorage = switch typeof window
  when 'undefined' then {getItem: (-> 'null'), setItem: (->)}
  else window.localStorage or {getItem: (-> 'null'), setItem: (->)}

ResultsPage = React.createClass
  defaultName: 'ResultsPage'
  getInitialState: -> @props or {rows: []}

  componentDidMount: ->
    if @state.rows and @state.rows.length
      @applyMasonry()
    else
      fetchCoords null, null, null, @fetch

  componentDidUpdate: ->
    @applyMasonry()

  applyMasonry: ->
    container = @refs.results.getDOMNode()
    imagesLoaded container, =>
      @masonry = new Masonry container, {
        columnWidth: 320
        itemSelector: '.doula-card'
      }
      @masonry.bindResize()

  updateMasonry: ->
    if @masonry
      setTimeout (=> @masonry.layout()), 401

  render: ->
    (div
      className: 'search'
    ,
      (form
        onSubmit: @handleSubmit
      ,
        (span className: 'logo',
          'doulas.club'
        )
        (input
          placeholder: 'Procure por nomes, cidades, conhecimentos da doula...'
          name: 'q'
          ref: 'q'
          onChange: @prepareFetch
          onBlur: @prepareFetch
        )
        (button
          type: 'submit',
          'PROCURAR'
        )
      )
      (div
        className: 'results'
        ref: 'results'
      ,
        (=>
          cards = []
          for row in @state.rows
            props = row.doc
            props.onMouseEnter = @updateMasonry
            props.onMouseLeave = @updateMasonry
            props.key = row.id
            cards.push (DoulaCard props)
          return cards
        )() if @state.rows
      )
    )

  timeout: null
  handleSubmit: (e) ->
    e.preventDefault() if e
    clearTimeout @timeout
    @fetch()

  prepareFetch: (e) ->
    e.preventDefault if e
    clearTimeout @timeout
    setTimeout @fetch, 2000

  fetch: ->
    q = @refs.q.getDOMNode().value
    fetchResults window.coords, {q: q}, (err, res) =>
      @setState res
      history.replaceState JSON.stringify(res), null, location.href

DoulaCard = React.createClass
  getInitialState: ->
    iframe: false

  render: ->
    (div
      className: 'doula-card' +
                 if not @props.foto then ' no-foto' else ''
      onMouseEnter: @handleMouseEnter
      onMouseLeave: @handleMouseLeave
    ,
      (Link
        href: '/doula/' + @props._id
        data: @props
      , (h2 {}, @props.nome)) if not @props.foto
      (header {},
        (Link
          href: '/doula/' + @props._id
          data: @props
        , (img src: @props.foto)) if @props.foto
        (ul className: 'attrs-list',
          (li {}, @props.cidade)
          (li {key: tel}, tel) for tel in [].concat @props.tel if @props.tel
          (li {key: email}, email) for email in [].concat @props.email if @props.email
          (li {key: site}, (a {href: site, title: site, target: '_blank'}, site)) for site in [].concat(@props.site) if @props.site
          (li {}, (a {href: @props.facebook, target: '_blank'}, @props.facebook.split('/').slice(-1)[0])) if @props.facebook
        )
      )
      (Link
        href: '/doula/' + @props._id
        data: @props
      , (h2 {}, @props.nome)) if @props.foto
      (div
        className: 'intro'
        dangerouslySetInnerHTML:
          __html: marked @props.intro
      ) if @props.intro
      (iframe
        src: @props.iframe
      ) if @state.iframe and @props.iframe
    )

  handleMouseEnter: ->
    @props.onMouseEnter()
    setTimeout (=>
      @timeout = @setState iframe: true
    ), 250

  handleMouseLeave: ->
    clearTimeout @timeout
    @props.onMouseLeave()

fetchCoords = (props, querystring, arbitraryData, callback) ->
  coords =
    manual: null
    browser: null
    ip: null

  # universal: manually setting the coords wins over the other methods
  if querystring and querystring.lat and querystring.lng
    coords.manual =
      longitude: querystring.lng
      latitude: querystring.lat
    callback null, coords, querystring

  if arbitraryData and typeof arbitraryData is 'object' and arbitraryData.connection
    # server and crawler bot, get the coords from the ip
    req = arbitraryData

    # check crawler
    #isCrawler = require 'is-crawler'
    #if not isCrawler req.get 'user-agent'
    #  # if not crawler, go on without coords
    #  return callback null, null, null
    return callback null, null, null

    # for a crawler, let's do a proper request parsing and fetch data
    ip = req.get('x-forwarded-for')
    if ip
      ip = ip.split(',')[0].trim()
    else
      ip = req.connection.remoteAddress

    superagent.get 'http://freegeoip.net/json/' + ip, (err, res) =>
      if not err
        coords.ip = res.body
      return callback null, coords, querystring

  else if typeof window isnt 'undefined'
    # client, try various things, use what finishes first
    if not coords.browser
      navigator.geolocation.getCurrentPosition (pos) =>
        coords.browser = pos.coords
        callback null, coords, querystring
    else
      callback null, coords, querystring

    if not coords.ip
      superagent.get 'http://freegeoip.net/json/', (err, res) =>
        if not err
          coords.ip = res.body
        callback null, coords, querystring if not coords.browser
    else
      callback null, coords, querystring

    # save coords to window
    window.coords = coords

fetchResults = (coords, querystring, callback) ->
  if not coords and not querystring
    # this is the case for a normal client use,
    # let's just return the raw html without
    # fetching data.
    return callback null, null

  # params for querying the database
  params = {}

  # add coords
  coords = coords.manual or coords.browser or coords.ip or coords.local
  if coords and coords.latitude and coords.longitude
    params.near = "#{coords.latitude},#{coords.longitude}"

  # add manual search input
  if querystring.q
    params.q = querystring.q

  # fetch
  endpoint = if typeof window is 'undefined' then process.env.ENDPOINT else ''
  superagent.get(endpoint + '/api/doulas')
            .query(params)
            .end (err, res) =>
    return console.log err if err

    callback err, (if res then res.body else null)


module.exports = ResultsPage
module.exports.fetchCoords = fetchCoords
module.exports.fetchResults = fetchResults
