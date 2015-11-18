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
    @animationsList = Animations.getAll()

  render: ->
    @currentDevice = @parent.getCurrentDevice()
    @currentMappingProfile = @parent.getCurrentMappingProfile()

    $(@el).html @template({
      currentDevice: if @currentDevice? then @currentDevice.toJSON() else null
      currentMappingProfile: if @currentMappingProfile? then @currentMappingProfile.toJSON() else null
    })

    if @currentDevice?
      @renderProfileMappings(mappingProfile) for mappingProfile in @currentDevice.get('mapping_profiles')
    return @

  renderProfileMappings: (mappingProfile) ->
    $("#mp-" + mappingProfile.cid).html mappingsTemplate({
      mappingProfile: mappingProfile.toJSON()
      animations: @animationsList
    })
    $("#col-#{@currentMappingProfile.cid}").addClass("in") # TODO: Do this in HBS

  events: ->
    "click #tour-trigger": "startTour"
    "shown.bs.collapse .profile-collapse" : "expandProfile"
    "hide.bs.collapse .profile-collapse" : "collapseProfile"
    "click #save-profile" : "saveDevice"
    "click #add-profile" : "addProfile"
    "click .del-profile" : "deleteProfile"
    "click .trigger-map" : "triggerAnimation"
    "click .remove-map": "unsetAnimation"
    "change .bpm-input": "setBPM"
    "submit .bpm-input form, .profile-title form": (e) ->
      $(e.currentTarget).find('input[type=number]').blur()
      e.preventDefault()
    "change input[name=selected-profile]": "changeProfile"
    "change select[name=animation]": "setAnimation"
    "change .profile-title" : "setTitle"

  startTour: (e) ->
    @parent.startTour()

  setAnimation: (e) ->
    ele = $(e.currentTarget)
    profileCid = ele.data('profileCid')
    midiCode = ele.data('midiCode')
    animationKey = ele.val()
    @parent.setAnimation(profileCid, midiCode, animationKey)

  unsetAnimation: (e) ->
    profileCid = $(e.currentTarget).data('profileCid')
    code = $(e.currentTarget).data('midiCode')
    @parent.unsetAnimation(profileCid, code)

  triggerAnimation: (e) ->
    ele = $(e.currentTarget)
    profileCid = ele.data('profileCid')
    midiCode = ele.data('midiCode')
    @parent.triggerAnimation(profileCid, midiCode)

  highlightMidiCode:(code) ->
    @clearSelections()
    id = "#map-"+@currentMappingProfile.cid+"-"+code
    $(id).addClass("selected-map")

  clearSelections:() ->
    $(".map").removeClass("selected-map")

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
    @render()

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

  setTitle: (e) ->
    title = $(e.currentTarget).find("input").val()
    profileCid = $(e.currentTarget).data("profileCid")
    mp = @currentDevice.getProfileFromCid(profileCid).setTitle(title)


