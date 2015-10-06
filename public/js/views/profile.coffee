BaseView = require "./baseView.coffee"
profileTemplate = require '../templates/profile.hbs'

AuthHelper = require "../helpers/auth.coffee"

module.exports = BaseView.extend
  el: "#main-wrapper"
  template: profileTemplate
  initialize: ->
  render: ->
    @model = new global.SvnthApp.Models.User({ id: AuthHelper.getUserId() })
    model = @model
    el = @el
    template = @template
    @model.fetch(
      headers: AuthHelper.getAuthHeaders()
      success: ->
        $(el).html template({ user: model.toJSON() })
    )
