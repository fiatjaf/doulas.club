deps = ['lib/react', 'lib/marked']

factory = (React, marked) ->
  module = {}
  module.exports = {}

  {html, body, meta, script, link, title,
   nav, div, iframe, ul, li, header, article,
   span, p, a, h1, h2, h3, h4, img,
   form, input, button} = React.DOM

  marked.setOptions
    gfm: true
    smartLists: true
    breaks: true
    sanitize: true
  
  DoulaCard = React.createFactory React.createClass
    getInitialState: ->
      iframe: false

    componentWillMount: ->
      @colors = @props.colors or window.colors or {}
  
    render: ->
      foto = null
      if @props.useExternalFoto
        foto = @props.foto
      if not foto and @props._attachments
        for key, data of @props._attachments
          if data.content_type.split('/')[0] == 'image' and
             data.length > 100
            foto = "#{@props.baseURL or ''}/#{@props._id}/#{key}"

      (div
        className: 'doula-card' +
                   if not foto then ' no-foto' else ''
        onMouseEnter: @handleMouseEnter
        onMouseLeave: @handleMouseLeave
      ,
        (a
          href: '/' + @props._id
          data: @props
        , (h2 {}, @props.nome)) if not foto
        (header {},
          (a
            href: "#{@props.baseURL or ''}/#{@props._id}"
            data: @props
          , (img src: foto)) if foto
          (ul className: 'attrs-list',
            (li {}, @props.cidade)
            (li {key: tel}, tel) for tel in [].concat @props.tel if @props.tel
            (li {key: email}, email) for email in [].concat @props.email if @props.email
            (li {key: site}, (a {href: site, title: site, target: '_blank'}, site)) for site in [].concat(@props.site) if @props.site
            (li {}, (a {href: @props.facebook, target: '_blank'}, 'facebook')) if @props.facebook
          )
        )
        (a
          href: "#{@props.baseURL or ''}/#{@props._id}"
          data: @props
        , (h2 {}, @props.nome)) if foto
        (div
          className: 'intro'
        ,
          (div
            dangerouslySetInnerHTML:
              __html: marked @props.intro
          ) if @props.intro
          (span {},
            (img
              className: 'badge'
              src: "https://img.shields.io/badge/forma%C3%A7%C3%A3o-#{@props['formação']}-#{@colors[@props['formação']]}.svg"
              alt: "Formação: #{@props['formação']}"
            )
          ) if @props['formação']
          (span {},
            (img
              className: 'badge'
              src: "https://img.shields.io/badge/desde-#{@props.desde}-yellow.svg"
              alt: "doula desde #{@props.desde}"
            )
          ) if @props.desde
        )
        (iframe
          src: @props.iframe
        ) if @state.preload and @props.iframe and not window.mobile
      )

    componentWillUnmount: ->
      clearTimeout @fetchIframeTimeout
  
    fetchIframeTimeout: null
    handleMouseEnter: ->
      @props.onMouseEnter() if @props.onMouseEnter
      @fetchIframeTimeout = setTimeout (=>
        @setState preload: true
      ), 2000
  
    handleMouseLeave: ->
      clearTimeout @fetchIframeTimeout
      @props.onMouseLeave() if @props.mouseLeave

  module.exports = DoulaCard

  return module.exports

if typeof define == 'function' and define.amd
  define deps, factory
else if typeof exports == 'object'
  module.exports = factory.apply @, deps.map require
