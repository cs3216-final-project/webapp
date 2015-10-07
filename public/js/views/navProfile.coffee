BaseView = require "./baseView.coffee"
navProfileTemplate = require '../templates/navProfile.hbs'

AuthHelper = require "../helpers/auth.coffee"

module.exports = BaseView.extend
  el: '#nav-profile'
  template: navProfileTemplate
  initialize: ->
  render: ->
    if AuthHelper.isLoggedIn()
      @model = new global.SvnthApp.Models.User({ id: AuthHelper.getUserId() })
      model = @model
      el = @el
      template = @template
      @model.fetch(
        headers: AuthHelper.getAuthHeaders()
        success: ->
          $(el).html template({ user: model.toJSON() })
      )
    else
      $(@el).html @template()
