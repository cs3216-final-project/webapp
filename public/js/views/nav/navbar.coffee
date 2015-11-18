$ = require "jquery"

BaseView = require "../baseView.coffee"
navbarTemplate = require "../../templates/nav/navbar.hbs"

AuthHelper = require "../../helpers/auth.coffee"

module.exports = BaseView.extend
  el: '#syn-navbar'
  template: navbarTemplate
  initialize: ->
  render: ->
    route = Backbone.history.getFragment()
    if AuthHelper.isLoggedIn()
      @model = new global.SvnthApp.Models.User({ id: AuthHelper.getUserId() })
      model = @model
      el = @el
      template = @template
      @model.fetch(
        headers: AuthHelper.getAuthHeaders()
        success: ->
          $(el).html template({ user: model.toJSON(), route: route })
      )
    else
      $(@el).html @template({ route: route })
    return @

  restartNavProfile: ->
    @close()
    @render()

  showNavbar: ()->
    $(".navbar").show()

  hideNavbar: () ->
    $(".navbar").hide()

