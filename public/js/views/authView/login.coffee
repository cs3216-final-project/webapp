$ = require "jquery"
BaseView = require "../baseView.coffee"

loginTemplate = require "../../templates/authTemplate/login.hbs"

AuthHelper = require "../../helpers/auth.coffee"

module.exports = BaseView.extend
  template: loginTemplate
  initialize: ->
  render: ->
    @$el.html @template()
    return @

  events:
    "submit #login-form" : "submitLoginForm"

  submitLoginForm: (e) ->
    e.preventDefault()
    $.ajax
      type: 'POST'
      url: global.SvnthApp.Config.apiUrl + 'user/auth'
      data: @$("#login-form").serialize()
      success: (response) ->
        AuthHelper.loginSuccess(JSON.parse(response))

        global.SvnthApp.router.navigate("/", { trigger: true })

      error: (xhr, statusCode, errorMessage)->
        alert(statusCode + ": " + errorMessage)
