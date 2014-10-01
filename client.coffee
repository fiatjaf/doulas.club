React = require 'react'
ReactAsync = require 'react-async'
ReactRouter = require 'react-router-component'
Pages = ReactRouter.Pages
Page = ReactRouter.Page
Link = ReactRouter.Link
NotFound = ReactRouter.NotFound

superagent = require 'superagent'
endpoint = 'http://162.243.206.108:3000'

{html, head, body, title, meta, link, script
 div, iframe, ul, li,
 span, a, h1, h2, h3, h4, img,
 form, input, button} = React.DOM

ResultsPage = React.createClass
  getInitialState: ->
    rows: []

  coords:
    ip: null
    browser: null
    manual: null

  componentDidMount: ->
    navigator.geolocation.getCurrentPosition (pos) ->
      @coords.browser = pos.coords
      @fetchResults()

    superagent.get 'http://freegeoip.net/json/', (err, res) ->
      if not err
        @coords.ip = res.body
        if not @coords.browser
          @fetchResults()

  fetchResults: ->
    clearTimeout @timeout

    querystring = if typeof window isnt 'undefined' then location.search else ''
    params = qs.parse querystring

    # add geolocation
    coords = @coords.manual or @coords.browser or @coords.ip
    if coords
      params.near = "#{coords.latitude},#{@coords.longitude}"

    # add manual search input
    params.q = @refs.q.getDOMNode().value

    superagent.get(endpoint + '/doulas')
              .query(params)
              .end (err, res) ->
      return console.log err if err
      @setState res.body

  render: ->
    (Html title: @state.nome,
      (form
        className: 'search'
        onSubmit: @fetchResults
      ,
        (input ref: 'q', onChange: @handleChange)
        (button
          type: 'submit',
          'PROCURAR'
        )
      )
      (div className: 'results',
        (DoulaCard doc: row.doc) for row in @state.rows
      )
    )

  timeout: null
  handleChange: ->
    clearTimeout @timeout
    setTimeout @fetchResults, 2000

DoulaCard = React.createClass
  render: ->
    (div className: 'doula-card',
      (h2 {}, @props.nome)
      (img src: @props.foto)
    )

DoulaPage = React.createClass
  mixins: [ReactAsync.Mixin]
  getInitialStateAsync: (cb) ->
    superagent.get endpoint + '/api/doula/' + @props.id, (err, res) ->
      cb err, (res.body if res)

  render: ->
    (Html title: @state.nome,
      (div {className: 'doula-page'},
        (div {className: 'top-bar'},
          (h1 {}, @state.nome)
        )
        (iframe src: @state.iframe) if @state.iframe
      )
    )

NotFoundHandler = React.createClass
  componentDidMount: ->
    location.href = '/'

  render: -> (div {})

Html = React.createClass
  render: ->
    (html {},
      (head {},
        (meta charSet: 'utf-8')
        (link rel: 'stylesheet', href: 'http://cdn.rawgit.com/picnicss/picnic/master/releases/v1.1.min.css')
        (link rel: 'stylesheet', href: '/assets/style.css')
        (title {},
          if @props.title then @props.title + ' | dou.land'
          else 'dou.land, o diretório brasileiro de doulas'
        )
      )
      @props.children
    )

App = React.createClass
  render: ->
    (Pages
      className: 'App'
      path: @props.path
    ,
      (Page items: @props.items, path: '/', handler: ResultsPage)
      (Page items: @props.items, path: '/doula/:id', handler: DoulaPage)
      (NotFound handler: NotFoundHandler)
    )
    (script src: '/assets/bundle.js')
    #(script
    #  dangerouslySetInnerHTML:
    #    __html: '''
    #  (function(t,r,a,c,k){k=r.createElement('script');k.type='text/javascript';
    #  k.async=true;k.src=a;r.getElementsByTagName('head')[0].appendChild(k);
    #  t.maq=[];t.mai=c;t.ma=function(){t.maq.push(arguments)};
    #  })(window,document,'http://static.microanalytics.alhur.es/tracker.js','b7nwbi38ahi6jk');

    #  ma('pageView');
    #    '''
    #)

module.exports = App
if typeof window isnt "undefined"
  window.onload = ->
    React.renderComponent App(), document
