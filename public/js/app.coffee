'use strict'

$ = require 'jquery'
AuthHelper = require "./helpers/auth.coffee"

Svnth = ->
  @Config = require './config.coffee'
  @Collections =
    Devices: require "./collections/devices.coffee"
  @Models =
    User: require "./models/user.coffee"
    Device: require "./models/device.coffee"
    Mapping: require "./models/mapping.coffee"
  @Views =
    MainVisuals: require './views/mainVisuals.coffee'
    Mappings: require './views/mappings.coffee'
    Signup: require './views/signup.coffee'
    Login: require './views/login.coffee'
    NavProfile: require './views/navProfile.coffee'
    Profile: require './views/profile.coffee'
  @beforeInit = ->

  @afterInit = ->

  @init = ((initData) ->
    @beforeInit.apply this  if typeof (@beforeInit) is 'function'
    @collections =
      devices: new S.Collections.Devices()
    @views =
      mainVisuals: new S.Views.MainVisuals()
      mappings: new S.Views.Mappings()
      signup: new S.Views.Signup()
      login: new S.Views.Login()
      navProfile: new S.Views.NavProfile()
      profile: new S.Views.Profile()
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
    json

  Backbone.history.start
    root: S.Config.appRoot
