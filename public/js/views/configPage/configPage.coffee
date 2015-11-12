$ = require "jquery"

Animations = require "../../helpers/animations.coffee"

BaseView = require "../baseView.coffee"
CanvasView = require "./canvas.coffee"
MapProfilesView = require "./mapProfiles.coffee"
MidiSettingsView = require "./midiSettings.coffee"

Device = require "../../models/device.coffee"

configTemplate = require "../../templates/configPage/configPage.hbs"

module.exports = BaseView.extend
  el: "#main-wrapper"
  template: configTemplate
  initialize: ->
    @devices = global.SvnthApp.collections.devices
  initSubViews: ->
    @canvasView = new CanvasView()
    @mapProfilesView = new MapProfilesView()
    @midiSettingsView = new MidiSettingsView()
  render: ->
    $(@el).html @template()
    @assign(@canvasView, "#animcanvas")
    @assign(@mapProfilesView, "#map-profile")
    @assign(@midiSettingsView, "#settings")
    return @

  getCurrentDevice: () ->
    return @currentDevice

  getCurrentMappingProfile: () ->
    return @currentMappingProfile

  getCurrentMappingCode: () ->
    return @currentMappingCode

  getAllDevices: () ->
    return @devices

  setCurrentDevice: (device) ->
    @currentDevice = device
    @assign(@mapProfilesView, "#map-profile")

  setCurrentMappingCode: (code) ->
    @currentMappingCode = code
    anim = @currentMappingProfile.getMap(@currentMappingCode).animation

  setCurrentMappingProfile: (mp) ->
    @currentMappingProfile = mp
    @currentMappingCode = null
    @midiSettingsView.render()

  setAllDevices: (devices) ->
    @devices = devices
    @setDevice(@devices.first()) if @devices.size() > 0

  updateCurrentDevice: (device) ->
    @currentDevice = device

  addNewCode: (code) ->
    @currentMappingProfile.setMap(code, Animations.getDefault()["key"])

  setAnimation: (profileCid, code, animationKey) ->
    mappingProfile = @currentDevice.getProfileFromCid profileCid
    mappingProfile.setMap(code, animationKey)
    @play(animationKey)

  unsetAnimation: (profileCid, code) ->
    mappingProfile = @currentDevice.getProfileFromCid profileCid
    mappingProfile.unsetMap(code)
    @mapProfilesView.renderProfileMappings(mappingProfile)

  triggerAnimation: (profileCid, code) ->
    mappingProfile = @currentDevice.getProfileFromCid profileCid
    @play mappingProfile.getMap(code).animation

  triggerCode: (code) ->
    animationMap = @currentMappingProfile.getMap(code)
    if animationMap?
      @play animationMap.animation
    else
      @addNewCode code
      @play @currentMappingProfile.getMap(code).animation
      @mapProfilesView.renderProfileMappings(@currentMappingProfile)

    @mapProfilesView.highlightMidiCode code

  play: (anim) ->
    if @currentMappingProfile
      @canvasView.playAnimation(anim, @currentMappingProfile.getBPM())
    else
      @canvasView.playAnimation(anim)

  renderEverythingButMapProfile: () ->
    @assign(@midiSettingsView, "#settings")
    @assign(@canvasView, "#animcanvas")

  ### DEVICE FUNCTIONS ###
  setDevice: (device) ->
    @currentDevice = device
    mappingProfiles = device.get("mapping_profiles")
    @currentDevice.addDefaultProfile() unless mappingProfiles? && mappingProfiles.length > 0
    @currentMappingProfile = @currentDevice.get('mapping_profiles')[0]
    @setCurrentMappingProfile(@currentMappingProfile)
    @render()

  addDevice: (device) ->
    deviceModel = new Device({ name: device.name, given_id: device.id, connected: true })
    dbDevices = (item for item in @devices.models when item.get('given_id') == deviceModel.get('given_id'))
    if dbDevices.length == 0
      @devices.add(deviceModel)
      @setDevice(deviceModel) if @devices.size() == 1 # first device
    else if dbDevices.length == 1
      dbDevices[0].set('connected', true)
    else
      throw 'Inconsistent device state'

    @midiSettingsView.render()

  ###JUST FOR TESTING WITHOUT A MIDI CONTROLLER###
  midi: (message) ->
    @mapProfilesView.onMidiMessage(message)

