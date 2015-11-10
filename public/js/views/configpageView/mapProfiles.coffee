$ = require "jquery"
_ = require "underscore"

BaseView = require "../baseView.coffee"
mapProfilesTemplate = require "../../templates/configpageTemplate/mapProfiles.hbs"
mappingsTemplate = require "../../templates/configpageTemplate/mappings.hbs"

Device = require "../../models/device.coffee"
MappingProfile = require "../../models/mapping.coffee"

AuthHelper = require "../../helpers/auth.coffee"
Animations = require "../../helpers/animations.coffee"
MidiHelper = require "../../helpers/midi.coffee"

module.exports = BaseView.extend
  el: '#map-profile'
  template: mapProfilesTemplate

  initialize: (options) ->
    @parent = options.parent

  render: ->
    @currentDevice = @parent.getCurrentDevice()
    if @currentDevice
      $(@el).html @template({
        currentDevice: @currentDevice.toJSON()
      })
      @initMidiDeviceConnection()
    else
      $(@el).html @template({
      })
    return @
  events: ->
    "shown.bs.collapse .profile-collapse" : "selectProfile"
    "hide.bs.collapse .profile-collapse" : "unselectProfile"
    "click #save-profile" : "saveDevice"
    "click #add-profile" : "addProfile"
    "click .del-profile" : "deleteProfile"
    "click .trigger-map" : "selectMap"
    "click .remove-map": "removeMap"
    "change .bpm-input": "setBPM"


  ###
  METHODS FOR SELECTING AND UNSELECTING PROFILES
  ###
  selectProfile: (e) ->
    profileCID = e.currentTarget.id.substring(4)
    @currentMappingProfile = @currentDevice.getProfileFromCid(profileCID)

    @parent.setCurrentMappingProfile(@currentMappingProfile)
    @parent.renderEverythingButMapProfile()
    @openEditIcon(profileCID)

  openEditIcon: (id) ->
    @clearEditIcons()

    headid = "#"+"hd-"+ id
    $(headid).find(".edit-pen").hide()
    $(headid).find(".edit-ok").show()

  unselectProfile: (e) ->
    @currentMappingProfile = null

    @parent.setCurrentMappingProfile(@currentMappingProfile)
    @parent.renderEverythingButMapProfile()
    @clearEditIcons()
    @clearSelections()

  clearEditIcons: ->
    #everything is set to default
    $(".edit-pen").show()
    $(".edit-ok").hide()

  ###
  SAVING
  ###
  saveDevice: (e) ->
    if global.SvnthApp.views.configpage.getCurrentDevice()
      global.SvnthApp.views.configpage.getCurrentDevice().save({}, { headers: AuthHelper.getAuthHeaders() }).done () ->
        global.SvnthApp.views.configpage.updateCurrentDevice(global.SvnthApp.views.configpage.getCurrentDevice())
        console.log("saved")
        $("#save-alert").fadeIn(300).delay(2000).fadeOut(300);

  ###
  ADD PROFILES
  ###
  addProfile: (e) ->
    newmp = @currentDevice.addNewProfile()
    @currentMappingProfile = newmp

    @parent.updateCurrentDevice(@currentDevice)
    @parent.setCurrentMappingProfile(@currentMappingProfile)
    @parent.renderEverythingButMapProfile()

    @refreshAndSelect(newmp.cid)

  ###
  DELETE PROFILES
  ###
  deleteProfile: (e) ->
    profileCID = e.currentTarget.id.substring(4)
    @currentDevice.deleteProfileByCid(profileCID)
    @currentMappingProfile = null

    @parent.updateCurrentDevice(@currentDevice)
    @parent.setCurrentMappingProfile(@currentMappingProfile)
    @clearSelections()
    @parent.render()

  ###
  SET BPM FOR EACH PROFILE
  ###
  setBPM: (e) ->
    bpm = $(e.currentTarget).find("input").val()
    if !(bpm <= 0 || bpm > 200)
      @currentMappingProfile.setBPM(bpm)

    @parent.setCurrentMappingProfile(@currentMappingProfile)
    @parent.renderEverythingButMapProfile()
    @clearSelections()

  ###
  MIDI SETTINGS
  ###
  initMidiDeviceConnection: () ->
    self = @
    if navigator.requestMIDIAccess
      navigator.requestMIDIAccess(sysex: false).then(
        @onMIDISuccess.bind(self),
        @onMIDIFailure.bind(self)
      )
    else
      alert 'No MIDI support in your browser.'

  onMIDISuccess: (midiAccess) ->
    inputs = midiAccess.inputs.values()
    input = inputs.next()

    while input and !input.done
      input.value.onmidimessage = @onMidiMessage.bind(@)
      @parent.addDevice(input.value)
      input = inputs.next()

  onMIDIFailure: (e) ->
    console.err("No access to MIDI devices or your browser doesn't support WebMIDI API. Please use WebMIDIAPIShim " + e);

  onMidiMessage: (message) ->
    data = message.data
    console.log(data)
    return unless MidiHelper.isValid(data)
    code = data[1]
    @triggerCode(code)

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
    $(id).addClass("selected")

  clearSelections:() ->
    $(".map").removeClass("selected")

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

