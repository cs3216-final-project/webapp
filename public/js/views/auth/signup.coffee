$ = require "jquery"
BaseView = require "../baseView.coffee"

User = require "../../models/user.coffee"

signupTemplate = require "../../templates/auth/signup.hbs"

AuthHelper = require "../../helpers/auth.coffee"

module.exports = BaseView.extend
  template: signupTemplate
  initialize: ->
  render: ->
    @$el.html @template()
    return @

  events:
    "submit #signup-form" : "submitSignupForm"

  submitSignupForm: (e) ->
    e.preventDefault()
    params = {}
    @$el.find("#signup-form").serializeArray().map (x) ->
      params[x.name] = x.value
    user = new User(params)
    user.save({}, {
      headers: AuthHelper.getAuthHeaders()
      success: (model, response) ->
        alert "Successfully signed up. You can now login with your credentials"
        global.SvnthApp.router.navigate("/login", { trigger: true })
      error: (model, response) ->
        if response.status == 400
          errors = JSON.parse(response.responseText)
          status = ""
          for field, message of errors
            status += "#{field} #{message} \n"
          alert status
    })
