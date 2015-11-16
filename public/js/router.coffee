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
    "signup": "signup"
    "login": "login"
    "logout": "logout"
    "test": "test"
    "live/:key" : "live"

  requiresAuth:
    ['#profile', '']

  before: (params, next) ->
    isLoggedIn = AuthHelper.isLoggedIn()
    path = Backbone.history.location.hash.split('/')[0];
    needAuth = _.contains(@requiresAuth, path);

    global.SvnthApp.views.login.close()

    global.SvnthApp.views.navbar.restartNavProfile()
    global.SvnthApp.views.navbar.showNavbar()

    if needAuth && !isLoggedIn
      @navigate("/login", { trigger : true })
    else
      next()

  after: ->

  index: ->
    global.SvnthApp.views.configPage.initSubViews()
    global.SvnthApp.views.configPage.render()
    global.SvnthApp.views.navbar.render()

  signup: ->
    if AuthHelper.isLoggedIn()
      @navigate("/app", { trigger : true })
    global.SvnthApp.views.signup.setElement('#main-wrapper')
    global.SvnthApp.views.signup.render()

  login: ->
    if AuthHelper.isLoggedIn()
      @navigate("/app", { trigger : true })
    global.SvnthApp.views.login.setElement('#main-wrapper')
    global.SvnthApp.views.login.render()

  logout: ->
    AuthHelper.logout()
    @navigate("/", { trigger: true })

  live: (key) ->
    global.SvnthApp.views.navbar.hideNavbar()
    global.SvnthApp.views.live.setKey(key)
    global.SvnthApp.views.live.render()