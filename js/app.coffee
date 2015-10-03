'use strict'

$ = require 'jquery'

Svnth = ->
  @Config = require './config.coffee'
  @Collections = {}
  @Models =
    Visual: require './models/visual.coffee'
  @Views =
    MainVisuals: require './views/mainVisuals.coffee'
  @beforeInit = ->

  @afterInit = ->
  @init = ((initData) ->
    @beforeInit.apply this  if typeof (@beforeInit) is 'function'
    @views =
      mainVisuals: new S.Views.MainVisuals()
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