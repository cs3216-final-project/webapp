$ = require "jquery"
BaseView = require "./baseView.coffee"
midiTriggersTemplate = require '../templates/midiTriggers.hbs'

module.exports = BaseView.extend
  template: midiTriggersTemplate
  initialize: ->
  render: ->
    @$el.html @template()