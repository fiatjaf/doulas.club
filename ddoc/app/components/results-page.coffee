deps = ['lib/react', 'lib/marked', 'lib/superagent', 'lib/pouchdb-collate']

factory = (React, marked, superagent, pouchCollate) ->
  module = {}
  module.exports = {}

  {html, body, meta, script, link, title,
   nav, div, iframe, ul, li, header, article,
   span, a, h1, h2, h3, h4, img,
   form, input, button} = React.DOM

  marked.setOptions
    gfm: true
    smartLists: true
    breaks: true
    sanitize: true
  
  localStorage = switch typeof window
    when 'undefined' then {getItem: (-> 'null'), setItem: (->)}
    else window.localStorage or {getItem: (-> 'null'), setItem: (->)}
  
  ResultsPage = React.createClass
    defaultName: 'ResultsPage'
    mixins: [React.addons.LinkedStateMixin]
    getInitialState: ->
      q: @props.query.q or ''
      rows: @props.rows or []
  
    componentDidMount: ->
      requirejs ['imagesloaded', 'masonry']

      if @state.rows and @state.rows.length
        @applyMasonry()
      else
        @fetch(true)

      # change the title so the user can find the tab name
      # easier in his sea of tabs
      if not @props.query.q
        document.title = @props.baseTitle

      window.addEventListener 'popstate', (e) =>
        if e.state and e.state.pushed
          @setState q: e.state.q, => @fetch(true)
  
    componentDidUpdate: ->
      @applyMasonry()
  
    applyMasonry: ->
      requirejs ['imagesloaded', 'masonry'], (imagesLoaded, Masonry) =>
        container = @refs.results.getDOMNode()
        imagesLoaded container, =>
          @masonry = new Masonry container, {
            columnWidth: 320
            itemSelector: '.doula-card'
          }
          @masonry.bindResize()
  
    updateMasonry: ->
      if @masonry
        @masonryTimeout = setTimeout (=> @masonry.layout()), 201
  
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
            , @props.baseTitle)
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
            (div className: 'input',
              (input
                itemProp: 'query-input'
                type: 'text'
                placeholder: 'Procure por nomes, cidades, conhecimentos da doula...'
                valueLink: @linkState 'q'
                name: 'q'
              )
            )
            (div className: 'button',
              (button
                type: 'submit',
                'PROCURAR'
              )
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
          )() if @state.rows.length
        )
        (div className: 'bottom-utils',
          (button
            className: 'load-more'
            onClick: @actuallyFetch.bind @, @state.bookmark
          , '+') if not @state.fetching and
                    @state.total_rows > @state.rows.length
          (div
            className: 'loading'
            dangerouslySetInnerHTML:
              __html: '''<!--?xml version="1.0" encoding="utf-8"?-->
<svg width="88px" height="88px" xmlns="http://www.w3.org/2000/svg" viewBox="0 0 100 100" preserveAspectRatio="xMidYMid" class="uil-wave">
  <rect x="0" y="0" width="100" height="100" fill="none" class="bk"></rect>
  <path fill="white" d="M90,50c0,5.5-5.7,8.8-7.8,13.6s-0.3,11-4,14.7s-9.9,1.9-14.7,4S55.5,90,50,90 s-8.8-5.7-13.6-7.8s-11-0.3-14.7-4s-1.9-9.9-4-14.7S10,55.5,10,50s5.7-8.8,7.8-13.6s0.3-11,4-14.7s9.1-1.6,13.9-3.6S44.5,10,50,10 s9.8,6.2,14.6,8.2s10.1-0.1,13.7,3.5s2.2,10.6,4.3,15.4S90,44.5,90,50z">
    <animateTransform attributeName="transform" type="rotate" from="0 50 50" to="45 50 50" repeatCount="indefinite" dur="1"></animateTransform>
  </path>
  <path fill="#3d6d96" d="M80,50c0,4.1-4.3,6.6-5.8,10.2c-1.5,3.6-0.3,8.3-3,11c-2.7,2.7-7.4,1.5-11,3C56.6,75.7,54.1,80,50,80 s-6.6-4.3-10.2-5.8c-3.6-1.5-8.3-0.3-11-3c-2.7-2.7-1.5-7.4-3-11C24.3,56.6,20,54.1,20,50s4.3-6.6,5.8-10.2c1.5-3.6,0.3-8.3,3-11 s6.9-1.2,10.4-2.7C42.8,24.5,45.9,20,50,20s7.3,4.6,10.9,6.1c3.6,1.5,7.6-0.1,10.3,2.7c2.7,2.7,1.7,8,3.2,11.6S80,45.9,80,50z">
    <animateTransform attributeName="transform" type="rotate" from="45 50 50" to="0 50 50" repeatCount="indefinite" dur="1"></animateTransform>
  </path>
</svg>'''
          ) if @state.fetching
        )
      )
  
    handleSubmit: (e) ->
      e.preventDefault() if e

      if @state.q
        document.title = @state.q + ' | pesquisa ' + @props.baseTitle
      else
        document.title = @props.baseTitle

      if history
        history.pushState {pushed: true, q: @state.q}, null, '/search?q=' + @state.q
      if typeof ma == 'function'
        ma 'search', @state.q

      @fetch(true)
  
    fetch: (doFetchCoords=false) ->
      # reset search states that were saved in window
      window.q = ''
      window.coords.manual = null if window.coords
      # these states cannot exist between different search queries

      q = @state.q
      window.q = q

      # this is necessary so we know when we should replace the state
      # with the new results and when we should just append
      searchId = Math.random()

      if doFetchCoords
        fetchCoords {q: q}, (flags={}) =>

          # ignore written query if geolocation found a result
          # means the written query is not important, just the coordinates
          # like when someone types 'são paulo'
          if flags.coordsFromSearch
            q = ''
            window.coords.manual = flags.coordsFromSearch
            window.q = q

          # change the searchId when this flag is present
          # mainly for the case when, after searching with coords
          # from IP only, the user authorizes the browser coords
          # then we do the search again, but discard the old
          # results, instead of mixing them
          # (when the searchId is the same we mix the results)
          if flags.newSearch
            searchId = Math.random()

          @actuallyFetch(null, limit: 30, searchId: searchId)
      else
        @actuallyFetch(null, limit: 15, searchId: searchId)

    actuallyFetch: (bookmark, kwargs={}) ->
      @setState fetching: true

      fetchResults window.coords, {q: window.q, limit: kwargs.limit}, {bookmark: bookmark}, (err, res) =>
        console.log err if err
        @state.fetching = false
        if not bookmark

          if @state.rows and @state.searchId == kwargs.searchId
            # second (or third) result from a batch of searches
            rows = []
            rowIndex = {}
            for row in @state.rows.concat res.rows
              if row.order.length == 4 # has '-<score>' in the beggining
                score = row.order[0]
                row.finalScore = [62.5 + (score * -12.5), -row.order[2]]
              else if row.order.length == 3 # begins with '<distance>'
                distance = row.order[0]
                row.finalScore = [distance, -row.order[1]]

              # filter out duplicates
              if row.id of rowIndex
                if rowIndex[row.id].finalScore < row.finalScore
                  continue
                else
                  remove = rows.indexOf rowIndex[row.id]
                  rows.splice remove, 1
                  rowIndex[row.id] = row
              rowIndex[row.id] = row

              rows.push row

            rows.sort (a, b) -> pouchCollate.collate(a.finalScore, b.finalScore)
            @state.rows = rows

          else # first result from a (new) batch of searches
            q = @state.q
            @state = res
            @state.q = q
            @state.searchId = kwargs.searchId

          @setState @state

        else
          @state.rows = @state.rows.concat res.rows
          @state.bookmark = res.bookmark
          @setState @state
  
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
        ) if @state.preload and @props.iframe and not window.mobile
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

    componentWillUnmount: ->
      clearTimeout @fetchIframeTimeout
      clearTimeout @masonryTimeout
  
  fetchCoords = (query={}, callback) ->
    coords = window.coords or {
      manual: null
      browser: null
      ip: null
    }
  
    # manually setting the coords wins over the other methods
    if query.lat and query.lng
      coords.manual =
        lng: query.lng
        lat: query.lat
      window.coords = coords
      return callback()

    # if there is a typed search query, check if it has coordinates
    if query.q and ':' not in query.q
      superagent.get('https://maps.googleapis.com/maps/api/geocode/json')
                .query({address: '"' + query.q + '"'})
                .query({components: 'country:BR'})
                .query({sensor: true})
                .end (err, res) =>
        return if err
        first = res.body.results[0]
        if first and not first.partial_match and 'political' in first.types
          callback(coordsFromSearch: first.geometry.location)
  
    # otherwise try using the ip or the browser data
    if not coords.browser
      navigator.geolocation.getCurrentPosition (pos) =>
        coords.browser =
          lat: pos.coords.latitude
          lng: pos.coords.longitude
        # use browser data when available
        callback(newSearch: true) if not coords.manual
    else
      callback() if not coords.manual
  
    if not coords.ip
      superagent.get('https://www.telize.com/geoip')
                .end (err, res) =>
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
  
  fetchResults = (coords={}, query={}, params={}, callback) ->
    if not coords and not query
      # this is the case for a normal client use,
      # let's just return the raw html without
      # fetching data.
      return callback null, null

    # add coords
    coords = coords.manual or coords.browser or coords.ip or coords.local
    if coords and coords.lat and coords.lng
      params.sort = [
        "<distance,lng,lat,#{coords.lng},#{coords.lat},km>",
        "-boost"
      ]

    # add manual search input
    if query.q
      params.q = query.q
      params.sort.unshift '-<score>'
    else
      params.q = "lng:[-73 TO -34] AND lat:[-32 TO 3]"

    # fetch
    params.sort = JSON.stringify(params.sort)
    superagent.get('/_ddoc/_search/doulas')
              .set('Accept', 'application/json')
              .query(params)
              .query('include_docs': 'true')
              .query('limit': query.limit or 30)
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
