$ = require "jquery"
_ = require "underscore"

module.exports =  Backbone.Router.extend
  initialize: ->

  route: (route, name, callback) ->
    route = @_routeToRegExp(route)  unless _.isRegExp(route)
    if _.isFunction(name)
      callback = name
      name = ""
    callback = this[name]  unless callback
    router = this
    Backbone.history.route route, (fragment) ->
      args = router._extractParameters(route, fragment)
      next = ->
        callback and callback.apply(router, args)
        router.trigger.apply router, [ "route:" + name ].concat(args)
        router.trigger "route", name, args
        Backbone.history.trigger "route", router, name, args
        router.after.apply router, args

      router.before.apply router, [ args, next ]
    @

  routes:
    "": "index"

  before: (params, next) ->
    next()

  after: ->

  index: ->
    console.log("Index route")
