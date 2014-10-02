React = require 'react'
qs = require 'qs'
marked = require 'marked'

{html, body, meta, script, link, title,
 div, iframe, ul, li, header, article,
 span, a, h1, h2, h3, h4, img,
 form, input, button} = React.DOM

superagent = require 'superagent'
localStorage = switch typeof window
  when 'undefined' then {getItem: (-> 'null'), setItem: (->)}
  else window.localStorage or {getItem: (-> 'null'), setItem: (->)}

ResultsPage = React.createClass
  defaultName: 'ResultsPage'
  getInitialState: ->
    rows: []

  coords:
    ip: null
    browser: null
    manual: null
    local: JSON.parse localStorage.getItem 'coords'

  componentDidMount: ->
    navigator.geolocation.getCurrentPosition (pos) =>
      @coords.browser = pos.coords
      @fetchResults()
      localStorage.setItem 'coords', JSON.stringify @coords.browser

    superagent.get 'http://freegeoip.net/json/', (err, res) =>
      if not err
        @coords.ip = res.body
        if not @coords.browser
          @fetchResults()
          localStorage.setItem 'coords', JSON.stringify @coords.ip

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
        onSubmit: @fetchResults
      ,
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
        )()
      )
    )

  timeout: null
  lastInputValue: ''
  fetchResults: (q, e) ->
    if q and q.preventDefault
      q.preventDefault()
    if e and e.preventDefault()
      e.preventDefault()

    clearTimeout @timeout
    q = q or @refs.q.getDOMNode().value
    @lastInputValue = q

    querystring = if typeof window isnt 'undefined' then location.search else ''
    params = qs.parse querystring

    # add geolocation
    coords = @coords.manual or @coords.browser or @coords.ip or @coords.local
    if coords
      params.near = "#{coords.latitude},#{coords.longitude}"

    # add manual search input
    if q
        params.q = q

    superagent.get('/api/doulas')
              .query(params)
              .end (err, res) =>
      return console.log err if err
      @setState res.body

  prepareFetch: (e) ->
    e.preventDefault if e

    q = @refs.q.getDOMNode().value
    if q != @lastInputValue
      clearTimeout @timeout
      setTimeout (=> @fetchResults q), 2000

DoulaCard = React.createClass
  render: ->
    (div
      className: 'doula-card' +
                 if not @props.foto then ' no-foto' else ''
      onMouseEnter: @props.onMouseEnter
      onMouseLeave: @props.onMouseLeave
    ,
      (h2 {}, @props.nome) if not @props.foto
      (header {},
        (img src: @props.foto) if @props.foto
        (ul {},
          (li {}, "#{@props.cidade} #{
            if @props['região'] then ' (' + @props['região'] + ')' else ''
          }")
          (li {key: tel}, tel) for tel in [].concat @props.tel if @props.tel
          (li {key: email}, email) for email in [].concat @props.email if @props.email
          (li {key: site}, (a {href: site, title: site, target: '_blank'}, site)) for site in [].concat(@props.site) if @props.site
          (li {}, (a {href: @props.facebook, target: '_blank'}, @props.facebook.split('/').slice(-1)[0])) if @props.facebook
        )
      )
      (h2 {}, @props.nome) if @props.foto
      (div
        className: 'intro'
        dangerouslySetInnerHTML:
          __html: marked @props.intro
      ) if @props.intro
    )

module.exports = ResultsPage
