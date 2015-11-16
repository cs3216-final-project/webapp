$ = require "jquery"

BaseView = require "../baseView.coffee"
template = require "../../templates/live/live.hbs"

Animations = require "../../helpers/animations.coffee"
RTC = require "../../helpers/rtc.coffee"

module.exports = BaseView.extend
  el: "#main-wrapper"
  template: template
  initialize: ->
    @key =""
  render: ->
    @makeTemplate(true)
    @showMessage()
    @beginRTCConnection(@key)
    return @

  beginRTCConnection: () ->
    @rtc = new RTC(@key, false, @)

  makeTemplate: (waiting) ->
    $(@el).html @template({waiting:waiting})
    @animations = new Animations(".presentation-view")
  
  connected: () ->
    @makeTemplate(false)
    callback= () =>
      $(".rtc-sign").fadeOut('slow')

    setTimeout callback, 1000

  showMessage: ()->
    $(".rtc-sign").show()

  setKey: (key) ->
    @key = key
    
  playAnimation: (anim, bpm = null) ->
    console.log(anim)
    console.log(bpm)
    if bpm
      @animations.updateBPM(bpm)
    else
      @animations.updateBPM(128)
    @animate(anim)

    ### leave this here in case, we need to do the time check for when testing with a real midi device###
  # playAnimationWithMap: (map, currentBPM) ->
  #   return if(@lastCode && @lastCode == map.code && @lastTime && (Date.now() - @lastTime < 600))
  #   @lastCode = map.code
  #   @lastTime = Date.now()
  #   anim = map.animation
  #   @animations.updateBPM(currentBPM)
  #   @animate(anim)

  animate: (anim) ->
    @animations[anim+"Anim"]()
