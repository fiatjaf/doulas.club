React = require 'react'

{html, body, meta, script, link, title,
 div, iframe, ul, li,
 span, a, h1, h2, h3, h4, img,
 form, input, button} = React.DOM

DoulaPage = React.createClass
  getInitialState: -> @props

  render: ->
    (div {className: 'doula-page' +
                     if @state.iframe then '' else ' no-iframe'},
      (div {className: 'top-bar'},
        (h1 {}, @state.nome)
      )
      (iframe src: @state.iframe) if @state.iframe
    )

module.exports = DoulaPage
