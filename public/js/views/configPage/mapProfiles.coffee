$ = require "jquery"
_ = require "underscore"

BaseView = require "../baseView.coffee"
mapProfilesTemplate = require "../../templates/configPage/mapProfiles.hbs"
mappingsTemplate = require "../../templates/configPage/mappings.hbs"

Device = require "../../models/device.coffee"
MappingProfile = require "../../models/mapping.coffee"

AuthHelper = require "../../helpers/auth.coffee"
Animations = require "../../helpers/animations.coffee"
MidiHelper = require "../../helpers/midi.coffee"

module.exports = BaseView.extend
  el: '#map-profile'
  template: mapProfilesTemplate

  initialize: (options) ->
    @parent = global.SvnthApp.views.configPage

  render: ->
    @currentDevice = @parent.getCurrentDevice()
    @currentMappingProfile = @parent.getCurrentMappingProfile()
    $(@el).html @template({
      currentDevice: if @currentDevice? then @currentDevice.toJSON() else null
      currentMappingProfile: if @currentMappingProfile? then @currentMappingProfile.toJSON() else null
    })
    return @
  events: ->
    "shown.bs.collapse .profile-collapse" : "expandProfile"
    "hide.bs.collapse .profile-collapse" : "collapseProfile"
    "click #save-profile" : "saveDevice"
    "click #add-profile" : "addProfile"
    "click .del-profile" : "deleteProfile"
    "click .trigger-map" : "selectMap"
    "click .remove-map": "removeMap"
    "change .bpm-input": "setBPM"
    "change input[name=selected-profile]": "changeProfile"

  changeProfile: (e) ->
    profileCid = $(e.currentTarget).data("profileCid")
    @currentMappingProfile = @currentDevice.getProfileFromCid(profileCid)

    @parent.setCurrentMappingProfile(@currentMappingProfile)

  ###
  METHODS FOR SELECTING AND UNSELECTING PROFILES
  ###
  expandProfile: (e) ->
    profileCid = $(e.currentTarget).data("profileCid")
    $(@el).find("#edit-#{profileCid}").removeClass("glyphicon-triangle-right")
    $(@el).find("#edit-#{profileCid}").addClass("glyphicon-triangle-bottom")

  collapseProfile: (e) ->
    profileCid = $(e.currentTarget).data("profileCid")
    $(@el).find("#edit-#{profileCid}").removeClass("glyphicon-triangle-bottom")
    $(@el).find("#edit-#{profileCid}").addClass("glyphicon-triangle-right")

  saveDevice: (e) ->
    if global.SvnthApp.views.configPage.getCurrentDevice()
      global.SvnthApp.views.configPage.getCurrentDevice().save({}, { headers: AuthHelper.getAuthHeaders() }).done () ->
        global.SvnthApp.views.configPage.updateCurrentDevice(global.SvnthApp.views.configPage.getCurrentDevice())
        console.log("saved")
        $("#save-alert").fadeIn(300).delay(2000).fadeOut(300);

  addProfile: (e) ->
    newmp = @currentDevice.addNewProfile()
    @currentMappingProfile = newmp

    @parent.updateCurrentDevice(@currentDevice)
    @parent.setCurrentMappingProfile(@currentMappingProfile)
    @parent.renderEverythingButMapProfile()

    @refreshAndSelect(newmp.cid)

  deleteProfile: (e) ->
    profileCid = $(e.currentTarget).data("profileCid")
    @currentDevice.deleteProfileByCid(profileCid)
    @currentMappingProfile = null

    @parent.updateCurrentDevice(@currentDevice)
    @parent.setCurrentMappingProfile(@currentMappingProfile)
    @clearSelections()
    @parent.render()

  setBPM: (e) ->
    bpm = $(e.currentTarget).find("input").val()
    if !(bpm <= 0 || bpm > 200)
      @currentMappingProfile.setBPM(bpm)

    @parent.setCurrentMappingProfile(@currentMappingProfile)
    @parent.renderEverythingButMapProfile()
    @clearSelections()

  ###
  MAP REMOVE, TRIGGER, SELECT
  ###
  removeMap: (e) ->
    code = $(e.currentTarget).data('midicode')
    @currentMappingProfile.unsetMap(code)
    @renderOnlyMappings()
    @parent.setCurrentMappingProfile(@currentMappingProfile)
    @parent.renderEverythingButMapProfile()

  selectMap: (e) ->
    code = $(e.currentTarget).data('midicode')
    @makeSelection(code)
    @updateCodeToParent(code)

  makeSelection:(code) ->
    @clearSelections()
    id = "#map-"+@currentMappingProfile.cid+"-"+code
    $(id).addClass("selected-map")

  clearSelections:() ->
    $(".map").removeClass("selected-map")

  updateCodeToParent: (code) ->
    @currentMappingCode = code
    @parent.setCurrentMappingCode(code)

  scrollToCode: (code)->
    id = "map-"+@currentMappingProfile.cid+"-"+code
    bpmpos =$("#bpm-"+@currentMappingProfile.cid).position().top
    colid = "#mp-"+@currentMappingProfile.cid
    offset = $(document.getElementById(id)).position().top - bpmpos
    $(colid).scrollTop(offset)
    console.log(offset)

  ###
  FOR TRIGGER FROM MIDI
  ###
  triggerCode: (code) ->
    if @currentMappingProfile
      if @currentMappingProfile.getMap(code)
        @makeSelection(code)
        @scrollToCode(code)
        @updateCodeToParent(code)
      else
        @parent.addNewCode(code)
        @currentMappingProfile = @parent.getCurrentMappingProfile()
        @renderOnlyMappings()
        @makeSelection(code)
        @scrollToCode(code)
        @updateCodeToParent(code)

  ###
  HELPER METHODS
  ###
  refreshAndSelect: (cid) ->
    @render()
    button = "#edit-"+cid
    $(button).click()

  renderOnlyMappings: () ->
    $("#mp-"+@currentMappingProfile.cid).html mappingsTemplate({
      currentMappingProfile: @currentMappingProfile
    })

