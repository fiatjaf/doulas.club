React = require 'react'
superagent = require 'superagent'

HTML = require './html'
DoulaPage = require './doula-page'
ResultsPage = require './results-page'
RRouter = require './react-router'
updatePage = RRouter.renderOrUpdatePage

router = RRouter [
  ['/', ResultsPage]
  ['/doula/:id', DoulaPage.fetchDoula, DoulaPage]
], HTML

module.exports = router

if typeof window isnt "undefined"
  window.onload = ->
    router.match location.pathname, (err, handler, data) ->
      return console.log err if err
      updatePage handler, data

    router.listenToPopState()
