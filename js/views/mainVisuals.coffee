$ = require "jquery"
BaseView = require "./baseView.coffee"
mainVisualsTemplate = require '../templates/mainVisuals.hbs'

module.exports = BaseView.extend
  template: mainVisualsTemplate
  initialize: ->
  render: ->
    @$el.html @template()