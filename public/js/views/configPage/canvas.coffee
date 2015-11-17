$ = require "jquery"

BaseView = require "../baseView.coffee"
template = require "../../templates/configPage/canvas.hbs"

RTC = require "../../helpers/rtc.coffee"
Animations = require "../../helpers/animations.coffee"

module.exports = BaseView.extend
  el: "#animcanvas"
  template: template
  initialize: (options) ->
    @parent = global.SvnthApp.views.configPage
    @createPresentationLink()
  render: ->
    $(@el).html @template({sharedkey: @key})
    @animations = new Animations("#visuals")
    return @

  createPresentationLink: () ->
    @key = Math.random().toString(36).substring(0,9).replace('.', '')
    @rtc = new RTC(@key,true)

  playAnimation: (anim, bpm = null) ->
    if bpm
      @sendAnimation(anim, bpm)
      @animations.updateBPM(bpm)
    else
      @sendAnimation(anim, 128)
      @animations.updateBPM(128)
    @animate(anim)

  sendAnimation: (anim, bpm) ->
    if @rtc.peerConnection? and @rtc.peerConnection.iceConnectionState != 'disconnected'
        message = {bpm: bpm, anim: anim}
        @rtc.dataChannel.send JSON.stringify(message)

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
