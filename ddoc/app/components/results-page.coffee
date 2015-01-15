deps = ['lib/react', 'lib/marked', 'lib/superagent']

factory = (React, marked, superagent) ->
  module = {}
  module.exports = {}

  {html, body, meta, script, link, title,
   nav, div, iframe, ul, li, header, article,
   span, a, h1, h2, h3, h4, img,
   form, input, button} = React.DOM
  
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
        fetchCoords null, => @fetch()

      # change the title so the user can find the tab name
      # easier in his sea of tabs
      parts = document.title.split(' | ')
      document.title = parts[1] + ' | ' + parts[0]
  
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
        setTimeout (=> @masonry.layout()), 201
  
    render: ->
      (div
        itemScope: true
        itemType: 'http://schema.org/SearchResultsPage'
        className: 'search-page'
      ,
        (nav {},
          (div className: 'main',
            (a
              itemProp: 'name'
              itemProp: 'url'
              href: '/'
            , 'doulas.club')
          )
          (form
            itemProp: 'potentialAction'
            itemScope: true
            itemType: 'http://schema.org/SearchAction'
            onSubmit: @handleSubmit
          ,
            (meta
              itemProp: 'target'
              content: '/search?q={query}'
            )
            (input
              itemProp: 'query-input'
              type: 'text'
              placeholder: 'Procure por nomes, cidades, conhecimentos da doula...'
              name: 'q'
              ref: 'q'
            )
            (button
              type: 'submit',
              'PROCURAR'
            )
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
  
    handleSubmit: (e) ->
      e.preventDefault() if e
      @fetch(true)
  
    fetch: (doFetchCoords=false) ->
      q = @refs.q.getDOMNode().value

      if doFetchCoords
        fetchCoords {q: q}, (flags={}) =>
          if flags.coordsFromSearch
            q = ''
            coords = {manual: flags.coordsFromSearch}
          else
            coords = window.coords
          @actuallyFetch coords, {q: q}
      else
        @actuallyFetch window.coords, {q: q}

    actuallyFetch: (coords, search_query) ->
      fetchResults coords, search_query, (err, res) =>
        console.log err if err
        @setState res
        history.replaceState JSON.stringify(res), null, location.href
  
  DoulaCard = React.createFactory React.createClass
    getInitialState: ->
      iframe: false
  
    render: ->
      (div
        className: 'doula-card' +
                   if not @props.foto then ' no-foto' else ''
        onMouseEnter: @handleMouseEnter
        onMouseLeave: @handleMouseLeave
      ,
        (a
          href: '/' + @props._id
          data: @props
        , (h2 {}, @props.nome)) if not @props.foto
        (header {},
          (a
            href: '/' + @props._id
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
        (a
          href: '/' + @props._id
          data: @props
        , (h2 {}, @props.nome)) if @props.foto
        (div
          className: 'intro'
          dangerouslySetInnerHTML:
            __html: marked @props.intro
        ) if @props.intro
        (iframe
          src: @props.iframe
        ) if @state.preload and @props.iframe
      )
  
    fetchIframeTimeout: null
    handleMouseEnter: ->
      @props.onMouseEnter()
      @fetchIframeTimeout = setTimeout (=>
        @setState preload: true
      ), 2000
  
    handleMouseLeave: ->
      clearTimeout @fetchIframeTimeout
      @props.onMouseLeave()
  
  fetchCoords = (querystring={}, callback) ->
    coords = window.coords or {
      manual: null
      browser: null
      ip: null
    }
  
    # manually setting the coords wins over the other methods
    if querystring.lat and querystring.lng
      coords.manual =
        lng: querystring.lng
        lat: querystring.lat
      window.coords = coords
      return callback()

    # if there is a typed search query, check if it has coordinates
    if querystring.q and ':' not in querystring.q
      superagent.get('http://maps.googleapis.com/maps/api/geocode/json')
                .query({address: '"' + querystring.q + '"'})
                .query({components: 'country:BR'})
                .query({sensor: true})
                .end (err, res) =>
        first = res.body.results[0]
        if not err and
           first and
           not first.partial_match and
           'political' in first.types
          callback({coordsFromSearch: first.geometry.location})
  
    # otherwise try using the ip or the browser data
    if not coords.browser
      navigator.geolocation.getCurrentPosition (pos) =>
        coords.browser =
          lat: pos.coords.latitude
          lng: pos.coords.longitude
        # use browser data when available
        callback() if not coords.manual
    else
      callback() if not coords.manual
  
    if not coords.ip
      superagent.get 'http://www.telize.com/geoip', (err, res) =>
        if not err
          coords.ip =
            lat: res.body.latitude
            lng: res.body.longitude
        # use ip data when available, but only when browser data isn't
        callback() if not coords.manual and not coords.browser
    else
      callback() if not coords.manual and not coords.browser
  
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
    if coords and coords.lat and coords.lng
      params.sort = [
        "<distance,lng,lat,#{coords.lng},#{coords.lat},km>",
        "-boost"
      ]

    # add manual search input
    if querystring.q
      params.q = querystring.q
      params.sort.unshift "relevance"
    else
      params.q = "lng:[-73 TO -34] AND lat:[-32 TO 3]"

    # fetch
    params.sort = JSON.stringify(params.sort)
    superagent.get('/_ddoc/_search/doulas')
              .set('Accept', 'application/json')
              .query(params)
              .query('include_docs': 'true')
              .query('limit': '30')
              .end (err, res) =>
      return console.log err if err
  
      callback err, (if res then res.body else null)

  module.exports = ResultsPage
  module.exports.fetchCoords = fetchCoords
  module.exports.fetchResults = fetchResults

  return module.exports

if typeof define == 'function' and define.amd
  define deps, factory
else if typeof exports == 'object'
  module.exports = factory.apply @, deps.map require
