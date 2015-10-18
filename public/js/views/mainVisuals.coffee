$ = require "jquery"

BaseView = require "./baseView.coffee"
template = require "../templates/mainVisuals.hbs"

Two = require "twojs-browserify"
Animations = require "../helpers/animations.coffee"

module.exports = BaseView.extend
  el: "#main-wrapper"
  template: template

  initialize: ->
  render: ->
    $(@el).html @template()
    @animations = new Animations()
    return @

  playAnimation: (anim) ->
    switch anim
      when "skybox"
        @animations.skyboxAnim()
      when "cube"
        @animations.cubeAnim()
