$ = require "jquery"
_ = require "underscore"

Animations = require "../../helpers/animations.coffee"
Keycode = require "../../helpers/keycode.coffee"

BaseView = require "../baseView.coffee"

playgroundTemplate = require "../../templates/playground/playground.hbs"

module.exports = BaseView.extend
  template: playgroundTemplate
  initialize: ->
    self = @
  render: ->
    _.bindAll(@, 'handleKeyboardTrigger')
    $(document).on('keydown', @handleKeyboardTrigger)
    @$el.html @template()
    @hideNavbar()
    Keycode.setDict()
    @animations = new Animations("#playground-visuals")
    return @
  events: ->
    "mousemove" : "fadeInNavbar"
    "mouseleave": "clearTimerForNavbar"

  hideNavbar: () ->
    $(".navbar").hide()

  fadeInNavbar: () ->
    if (!$('.navbar').is(':visible') )
      $(".navbar").fadeIn()

    @clearTimerForNavbar()

    callback = =>
      @fadeOutNavbar()
    @ctimer = setTimeout callback, 2000

  fadeOutNavbar: () ->
    $(".navbar").fadeOut()

  fadeOutHint: () ->
    if ($("#playground-hint").is(":visible") )
      $("#playground-hint").fadeOut()

    @clearTimerForHint()

    hintCallback = =>
      $("#playground-hint").fadeIn()
    @htimer = setTimeout hintCallback, 7000

  handleKeyboardTrigger: (e) ->
    if (e.metaKey || e.ctrlKey)
      return
    @fadeOutHint()
    @hideNavbar()
    e.preventDefault()
    code = e.keyCode || e.which
    if Keycode.getName(code)
      anim = _.sample(Animations.getAll()).key
      console.log(anim)
      @animations.updateBPM(128)
      @animate(anim)

  animate: (anim) ->
    @animations[anim+"Anim"]()

  clearTimerForNavbar: () ->
    clearTimeout(@ctimer)

  clearTimerForHint: () ->
    clearTimeout(@htimer)
