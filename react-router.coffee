React = require 'react'
ARouter = require './agnostic-router'

router = null
handlerCache = {}
HTML = null
RRouter = (routes, htmlComponent) ->
  router = ARouter routes
  HTML = htmlComponent

  router.listenToPopState = ->
    window.onpopstate = (e) ->
      if e.state
        handler = handlerCache[location.href]
        renderOrUpdatePage handler, JSON.parse(e.state)
      else
        router.match location.href (err, handler, data) ->
          return console.log err iferr
          renderOrUpdatePage handler, data

  return router

APP = null
renderOrUpdatePage = (handler, data) ->
  documentTitle = data.nome if data.nome
  try
    history.replaceState JSON.stringify(data), documentTitle, location.href
    handlerCache[location.href] = handler
  catch e

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

    if not @props.data
      router.match @props.href, (err, handler, data) ->
        return console.log err if err
        renderOrUpdatePage handler, data

    else
      router.matchWithData @props.href, @props.data, (err, handler) =>
        return console.log err if err
        renderOrUpdatePage handler, @props.data

module.exports = RRouter
module.exports.Link = Link
module.exports.renderOrUpdatePage = renderOrUpdatePage
