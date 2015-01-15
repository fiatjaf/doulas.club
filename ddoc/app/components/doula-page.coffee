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
      (div
        itemScope: true
        itemType: 'http://schema.org/Person'
        className: 'h-resume h-card doula-page' +
                   if @props.iframe then '' else ' no-iframe',
        (div className: 'top-bar',
          (div className: 'avatar full m-third l-third',
            (img
              itemProp: 'image'
              className: 'u-photo', alt: "foto da doula #{@props.nome}"
              src: @props.foto
            ) if @props.foto
            (h1
              itemProp: 'name'
              className: 'p-name replace-foto'
            , @props.nome) if not @props.foto
          )
          (div className: 'text full m-two-third l-third',
            (h1 {itemProp: 'name'}, @props.nome) if @props.foto
            (div
              className: 'intro e-note'
              dangerouslySetInnerHTML:
                __html: marked(@props.intro) if @props.intro
            )
          )
          (div className: 'p-summary full m-third l-sixth',
            (ul {className: 'attrs-list'},
              (li
                itemProp: 'alumniOf'
                itemScope: true
                itemType: 'http://schema.org/EducationalOrganization'
              , "formada pelo ",
                (span
                  itemProp: 'name'
                  className: 'p-education'
                , @props['formação'])
              ) if @props['formação']
              (li className: 'p-experience h-event',
                (span {className: 'p-name'}, "doula")
                " desde "
                (span {className: 'dt-start', dateTime: @props.desde}, @props.desde)
              ) if @props.desde
              (li
                itemProp: 'address'
                itemScope: true
                itemType: 'http://schema.org/PostalAddress'
              ,
                (span
                  itemProp: 'addressLocality'
                  className: 'p-locality'
                , @props.cidade)
              )
              (li {}, 'atende: ' + @props['região']) if @props['região']
              (li
                itemProp: 'telephone'
                className: 'p-tel'
                key: tel
              , tel) for tel in [].concat @props.tel if @props.tel
              (li
                itemProp: 'email'
                key: email
              , (a {href: 'mailto:' + email, className: 'u-email'}, email)
              ) for email in [].concat @props.email if @props.email
              (li {key: site}, (a {href: site, title: site, target: '_blank'}, site)) for site in [].concat(@props.site) if @props.site
              (li {}, (a {href: @props.facebook, target: '_blank'}, 'facebook')) if @props.facebook
            )
          )
          (div className: 'logo full m-third l-sixth',
            (a className: 'button error', href: '/',
              'doulas.club')
          )
        )
        (iframe
          itemProp: 'sameAs'
          className: 'u-url'
          src: @props.iframe
        ) if @props.iframe
      )
  
  module.exports = DoulaPage
  
  fetchDoula = (props, callback) ->
    superagent.get '/' + props.id, (err, res) ->
      callback err, (res.body if res)
  
  module.exports.fetchDoula = fetchDoula

  return module.exports

if typeof define == 'function' and define.amd
  define deps, factory
else if typeof exports == 'object'
  module.exports = factory.apply @, deps.map require
