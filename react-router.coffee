React = require 'react'
ARouter = require './agnostic-router'

router = null
HTML = null
RRouter = (routes, htmlComponent) ->
  router = ARouter routes
  HTML = htmlComponent
  router

APP = null
renderOrUpdatePage = (handler, data) ->
  documentTitle = data.nome if data.nome
  history.replaceState data, documentTitle, location.href
  APP = HTML title: documentTitle, body: handler(data)
  APP = React.renderComponent APP, document
  APP

Link = React.createClass
  render: ->
    (React.DOM.a
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
      renderOrUpdatePage handler, data

module.exports = RRouter
module.exports.Link = Link
module.exports.renderOrUpdatePage = renderOrUpdatePage
