'use strict'

$ = require 'jquery'
AuthHelper = require "./helpers/auth.coffee"

Svnth = ->
  @Config = require './config.coffee'
  @Collections = {}
  @Models =
    User: require "./models/user.coffee"
  @Views =
    MainVisuals: require './views/mainVisuals.coffee'
    Login: require './views/login.coffee'
    NavProfile: require './views/navProfile.coffee'
    Profile: require './views/profile.coffee'
  @beforeInit = ->

  @afterInit = ->

  @init = ((initData) ->
    @beforeInit.apply this  if typeof (@beforeInit) is 'function'
    @views =
      mainVisuals: new S.Views.MainVisuals()
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

  Backbone.history.start
    root: S.Config.appRoot
