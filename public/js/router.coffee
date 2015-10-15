$ = require "jquery"
_ = require "underscore"

AuthHelper = require "./helpers/auth.coffee"

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
    "profile": "profile"
    "login": "login"
    "logout": "logout"

  requiresAuth:
    ['#profile']

  before: (params, next) ->
    isLoggedIn = AuthHelper.isLoggedIn()
    path = Backbone.history.location.hash.split('/')[0];
    needAuth = _.contains(@requiresAuth, path);

    global.SvnthApp.views.profile.close()
    global.SvnthApp.views.login.close()

    global.SvnthApp.views.navProfile.close()
    global.SvnthApp.views.navProfile.render()

    if needAuth && !isLoggedIn
      @navigate("/login", { trigger : true })
    else
      next()

  after: ->

  index: ->
    global.SvnthApp.views.mainVisuals.render()
    global.SvnthApp.views.mappings.render()

  profile: ->
    global.SvnthApp.views.profile.render()

  login: ->
    if AuthHelper.isLoggedIn()
      @navigate("/profile", { trigger : true })
    global.SvnthApp.views.login.setElement('#main-wrapper')
    global.SvnthApp.views.login.render()

  logout: ->
    AuthHelper.logout()
    @navigate("/", { trigger: true })
