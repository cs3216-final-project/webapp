$ = require "jquery"

BaseView = require "../baseView.coffee"
template = require "../../templates/configPage/canvas.hbs"
fulltemplate = require "../../templates/configPage/fullCanvas.hbs"

Two = require "twojs-browserify"
Animations = require "../../helpers/animations.coffee"

module.exports = BaseView.extend
  el: "#animcanvas"
  template: template
  fulltemplate : fulltemplate
  initialize: (options) ->
    @parent = global.SvnthApp.views.configPage
  render: ->
    $(@el).html @template()
    @animations = new Animations("#visuals")
    return @
  events: ->
    "click .btn-fullscreen" : "setFullScreen"
    "click .btn-smallscreen" : "exitFullScreen"

  setFullScreen: (e) ->
    $(@el).html @fulltemplate()
    $(".non-visual").hide()
    $(".navbar").hide()
    @animations = new Animations("#fullscreen-visuals")
    #TODO: PLAY CURRENTLY RUNNING ANIMATION

  exitFullScreen: (e) ->
    $(".non-visual").show()
    $(".navbar").show()
    @render()
    #TODO: PLAY CURRENTLY RUNNING ANIMATION

  playAnimation: (anim, bpm = null) ->
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
