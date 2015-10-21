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

  playAnimation: (map, currentBPM) ->
    return if(@lastCode && @lastCode == map.code && @lastTime && (Date.now() - @lastTime < 600))
    @lastCode = map.code
    @lastTime = Date.now()
    anim = map.anim
    @animations.updateBPM(currentBPM)
    switch anim
      when "skybox"
        @animations.skyboxAnim()
      when "cube"
        @animations.cubeAnim()
      when "1.1_never"
        @animations.never1_1Anim()
      when "1.2_bgrandomcolor"
        @animations.bgrandomcolor1_2Anim()
      when "1.3_versescene"
        @animations.versescene1_3Anim()
      when "1.4_versescene"
        @animations.versescene1_4Anim()
      when "1.5_prechorus"
        @animations.prechorus1_5Anim()
      when "1.6_chorusscene"
        @animations.chorusscene1_6Anim()
      when "1.7_chorusscene"
        @animations.chorusscene1_7Anim()
      when "1.8_verse2scene"
        @animations.verse2scene1_8Anim()
      when "1.9_verse2scene"
        @animations.verse2scene1_9Anim()
      when "2.1_intro"
        @animations.intro2_1Anim()
      when "2.2a_prechorus"
        @animations.prechorus2_2aAnim()
      when "2.2b_prechorus"
        @animations.prechorus2_2bAnim()
      when "2.2c_prechorus"
        @animations.prechorus2_2cAnim()
      when "2.2d_prechorus"
        @animations.prechorus2_2dAnim()
      when "2.3_prechorus"
        @animations.prechorus2_3Anim()
      when "2.4a_chorus"
        @animations.chorus2_4aAnim()
      when "2.4b_chorus"
        @animations.chorus2_4bAnim()
      when "2.5a_verse"
        @animations.verse2_5aAnim()
      when "2.5b_verse"
        @animations.verse2_5bAnim()
      when "2.6_bridge"
        @animations.bridge2_6Anim()
      # when "linesphere"
      #   @animations.linesphereAnim()
      # when "squareparticles"
      #   @animations.squareparticlesAnim()
