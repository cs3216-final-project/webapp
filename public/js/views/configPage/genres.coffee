$ = require "jquery"

BaseView = require "../baseView.coffee"
template = require "../../templates/configPage/genres.hbs"
animtemplate = require "../../templates/configPage/animationList.hbs"


Animations = require "../../helpers/animations.coffee"

module.exports = BaseView.extend
  el: "#genres"
  template: template
  initialize:(options) ->
    @parent = global.SvnthApp.views.configPage
    @animArr = Animations.getAll()
  render: ->
    $(@el).html @template({
        animations: @animArr
    })
    return @
  events: ->
    "click .genre-btn" : "filterAnimations"
    "click .anim-btn": "playAnimation"

  filterAnimations: (e) ->
    if e.currentTarget.id == "gen-gifs"
      $(".genre-btn").removeClass("active")
      $("#gen-gifs").addClass("active")
      $("#anim-list-group").html animtemplate({
        gifs: @gifArr
      })
    else
      $("#gen-gifs").removeClass("active")
      # TODO grab the value and filter animations accordingly
      $("#anim-list-group").html animtemplate({
        animations: @animArr
      })

  playAnimation: (e) ->
    @clearSelection()
    if @parent.getCurrentMappingCode()
      @updateAnimation(e)
    else
      @animate(@getAnimId(e))

  updateAnimation: (e) ->
    anim = @getAnimId(e)
    @animate(anim)
    @makeSelection(anim)
    @updateParent(anim)

  getAnimId: (e) ->
    ele = $(e.currentTarget)
    animId = ele.val()

  animate: (anim) ->
    return if anim == ""
    @parent.play(anim)

  makeSelection: (anim) ->
    id = "anim-"+anim
    $(document.getElementById(id)).addClass("active")

  scrollToID: (anim) ->
    id = "anim-"+anim
    offset = $(document.getElementById(id)).position().top
    $("#anim-list-group").scrollTop($("#anim-list-group").scrollTop() + offset)

  updateParent: (anim) ->
    @parent.updateAnimations(anim)

  clearSelection: () ->
    $(".anim-btn").removeClass("active")

  ###
  FOR WHEN TRIGGERED FROM PARENT
  ###
  triggerAnimation: (anim) ->
    #can check if gif
    if !$("#gen-gifs").hasClass("active")
      @clearSelection()
      @animate(anim)
      @makeSelection(anim)
      @scrollToID(anim)
