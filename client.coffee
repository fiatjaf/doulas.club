React = require 'react'
Router = require './router'
superagent = require 'superagent'

DoulaPage = require './doula-page'
ResultsPage = require './results-page'

endpoint = 'http://162.243.206.108:3000'

{html, body, meta, script, link, title,
 div, iframe, ul, li,
 span, a, h1, h2, h3, h4, img,
 form, input, button} = React.DOM

FrozenHead = require 'react-frozenhead'
Html = React.createClass
  render: ->
    (html {},
      (FrozenHead {},
        (meta charSet: 'utf-8')
        (link rel: 'stylesheet', href: 'http://cdn.rawgit.com/picnicss/picnic/master/releases/v1.1.min.css')
        (link rel: 'stylesheet', href: '/assets/style.css')
        (title {},
          if @props.title then @props.title + ' | dou.land'
          else 'dou.land, o diretório brasileiro de doulas'
        )
      )

      (body {}, @props.body)

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
    )

Link = React.createClass
  render: ->
    (a
      className: @props.className
      href: @props.href
      onClick: @handleClick
    , @props.children)

  handleClick: (e) ->
    return if not history
    e.preventDefault()
    history.pushState null, null, @props.href
    router.match @props.href, (err, handler, data) ->
      return console.log err if err
      updatePage handler, data

module.exports =
  Html: Html
  Link: Link

fetchDoula = (props, cb) ->
  superagent.get endpoint + '/api/doula/' + props.id, (err, res) ->
    cb err, (res.body if res)

router = Router [
  ['/', ResultsPage]
  ['/doula/:id', fetchDoula, DoulaPage]
]

module.exports.router = router

APP = null
updatePage = (handler, data) ->
  documentTitle = data.nome if data.nome
  history.replaceState data, documentTitle, location.href
  APP = Html title: documentTitle, body: handler(data)
  APP = React.renderComponent APP, document

if typeof window isnt "undefined"
  window.onload = ->
    router.match location.pathname, (err, handler, data) ->
      return console.log err if err
      updatePage handler, data

    window.onpopstate = (e) ->
      if e.state
        updatePage handler, e.state
      else
        router.match location.pathname, (err, handler, data) ->
          return console.log err if err
          updatePage handler, data
