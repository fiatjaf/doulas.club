React = require 'react'
superagent = require 'superagent'
marked = require 'marked'

{html, body, meta, script, link, title,
 div, iframe, ul, li,
 span, a, h1, h2, h3, h4, img,
 form, input, button} = React.DOM

DoulaPage = React.createClass
  render: ->
    (div {className: 'doula-page' +
                     if @props.iframe then '' else ' no-iframe'},
      (div {className: 'top-bar'},
        (div className: 'full l-third',
          (img src: @props.foto)
          (h1 {className: 'replace-foto'}, @props.nome) if not @props.foto
        )
        (div className: 'full l-third',
          (h1 {}, @props.nome) if @props.foto
          (div
            dangerouslySetInnerHTML:
              __html: marked(@props.intro) if @props.intro
          )
        )
        (div className: 'full l-third',
          (ul {className: '.attrs-list'},
            (li {}, "formada pelo #{@props['formação']}") if @props['formação']
            (li {}, "doula desde #{@props.desde}") if @props.desde
            (li {}, @props.cidade)
            (li {}, 'atende: ' + @props['região']) if @props['região']
            (li {key: tel}, tel) for tel in [].concat @props.tel if @props.tel
            (li {key: email}, email) for email in [].concat @props.email if @props.email
            (li {key: site}, (a {href: site, title: site, target: '_blank'}, site)) for site in [].concat(@props.site) if @props.site
            (li {}, (a {href: @props.facebook, target: '_blank'}, @props.facebook.split('/').slice(-1)[0])) if @props.facebook
          )
        )
      )
      (iframe src: @props.iframe) if @props.iframe
    )

module.exports = DoulaPage

endpoint = if typeof window is 'undefined' then process.env.ENDPOINT else ''
module.exports.fetchDoula = (props, cb) ->
  superagent.get endpoint + '/api/doula/' + props.id, (err, res) ->
    cb err, (res.body if res)
