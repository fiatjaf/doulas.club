deps = ['lib/react', 'lib/superagent', 'lib/marked']

factory = (React, superagent, marked) ->
  module = {}
  module.exports = {}

  {html, body, meta, script, link, title,
   div, iframe, ul, li,
   span, a, h1, h2, h3, h4, img,
   form, input, button} = React.DOM
  
  DoulaPage = React.createClass
    render: ->
      (div {className: 'doula-page' +
                       if @props.iframe then '' else ' no-iframe'},
        (div className: 'top-bar',
          (div className: 'full l-third',
            (img src: @props.foto) if @props.foto
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
            (ul {className: 'attrs-list'},
              (li {}, "formada pelo #{@props['formação']}") if @props['formação']
              (li {}, "doula desde #{@props.desde}") if @props.desde
              (li {}, @props.cidade)
              (li {}, 'atende: ' + @props['região']) if @props['região']
              (li {key: tel}, tel) for tel in [].concat @props.tel if @props.tel
              (li {key: email}, email) for email in [].concat @props.email if @props.email
              (li {key: site}, (a {href: site, title: site, target: '_blank'}, site)) for site in [].concat(@props.site) if @props.site
              (li {}, (a {href: @props.facebook, target: '_blank'}, 'facebook')) if @props.facebook
            )
          )
        )
        (iframe src: @props.iframe) if @props.iframe
      )
  
  module.exports = DoulaPage
  
  fetchDoula = (props, callback) ->
    superagent.get '/' + props.id, (err, res) ->
      callback err, (res.body if res)
  
  exposeDocumentTitle = (doulaDoc, callback) ->
    doulaDoc.documentTitle = doulaDoc.nome if doulaDoc
    callback null, doulaDoc
  
  module.exports.fetchDoula = fetchDoula
  module.exports.exposeDocumentTitle = exposeDocumentTitle

  return module.exports

if typeof define == 'function' and define.amd
  define deps, factory
else if typeof exports == 'object'
  module.exports = factory.apply @, deps.map require
