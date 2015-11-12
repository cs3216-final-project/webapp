'use strict'

$ = require 'jquery'
Handlebars = require("handlebars/runtime")["default"]

AuthHelper = require "./helpers/auth.coffee"
helpers = require("./helpers/view_helpers.coffee")(Handlebars)

for own key, fn of helpers
  Handlebars.registerHelper(key, fn)

Svnth = ->
  @Config = require './config.coffee'
  @Collections =
    Devices: require "./collections/devices.coffee"
  @Models =
    User: require "./models/user.coffee"
    Device: require "./models/device.coffee"
    Mapping: require "./models/mapping.coffee"
  @Views =
    Signup: require './views/auth/signup.coffee'
    Login: require './views/auth/login.coffee'
    ConfigPage: require './views/configPage/configPage.coffee'
    NavBar: require './views/nav/navbar.coffee'
  @beforeInit = ->

  @afterInit = ->

  @init = ((initData) ->
    @beforeInit.apply this  if typeof (@beforeInit) is 'function'
    @collections =
      devices: new S.Collections.Devices()
    @views =
      configPage: new S.Views.ConfigPage()
      signup: new S.Views.Signup()
      login: new S.Views.Login()
      navbar: new S.Views.NavBar()
    @afterInit.apply this  if typeof (@afterInit) is 'function'
    return
  ).bind(this)
  return

S = new Svnth()
global.SvnthApp = S

$ ->
  S.init()
  Routers =
    Router : require './router.coffee'
  S.router = new Routers.Router()

  Backbone.Model::toJSON = ->
    json = _.clone(@attributes)
    for attr of json
      if json[attr] instanceof Backbone.Model or json[attr] instanceof Backbone.Collection
        json[attr] = json[attr].toJSON()
      else if json[attr] instanceof Array
        # hack to check if this is a Model/Collection array
        if json[attr][0] instanceof Backbone.Model or json[attr][0] instanceof Backbone.Collection
          json[attr] = (ele.toJSON() for ele in json[attr])
    json.cid = @cid
    json

  Backbone.history.start
    root: S.Config.appRoot
