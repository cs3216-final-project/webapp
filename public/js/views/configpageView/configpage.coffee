$ = require "jquery"

BaseView = require "../baseView.coffee"
GenresView = require "./genres.coffee"
CanvasView = require "./canvas.coffee"
MapProfilesView = require "./mapProfiles.coffee"
SettingsView = require "./settings.coffee"

Device = require "../../models/device.coffee"

configTemplate = require "../../templates/configpageTemplate/configpage.hbs"

module.exports = BaseView.extend
  el: "#main-wrapper"
  template: configTemplate
  initialize: ->
    self = @
    @genresView = new GenresView({parent: self})
    @canvasView = new CanvasView({parent: self})
    @mapProfilesView = new MapProfilesView({parent: self})
    @settingsView = new SettingsView({parent: self})
    @devices = global.SvnthApp.collections.devices
  render: ->
    $(@el).html @template()
    @assign(@canvasView, "#animcanvas")
    @assign(@mapProfilesView, "#map-profile")
    @assign(@genresView, "#genres")
    @assign(@settingsView, "#settings")
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
    @genresView.triggerAnimation(anim)

  setCurrentMappingProfile: (mp) ->
    @currentMappingProfile = mp
    @currentMappingCode = null

  setAllDevices: (devices) ->
    @devices = devices

  updateCurrentDevice: (device) ->
    @currentDevice = device
  
  addNewCode: (code) ->
    @currentMappingProfile.setMap(code, @canvasView.default())
    
  updateAnimations: (anim) ->
    @getCurrentMappingProfile().setMap(@getCurrentMappingCode(), anim)
    @mapProfilesView.renderOnlyMappings()

  play: (anim) ->
    if @currentMappingProfile
      @canvasView.playAnimation(anim, @currentMappingProfile.getBPM())
    else
      @canvasView.playAnimation(anim)

  renderEverythingButMapProfile: () ->
    @assign(@settingsView, "#settings")
    @assign(@genresView, "#genres")
    @assign(@canvasView, "#animcanvas")

  ### DEVICE FUNCTIONS ###
  setDevice: (device) ->
    @currentDevice = device
    @currentMappingProfile = null
    @setCurrentMappingProfile(@currentMappingProfile)
    @render()

  addDevice: (device) ->
    deviceModel = new Device({ name: device.name, given_id: device.id })
    dbDevices = (item for item in @devices.models when item.get('given_id') == deviceModel.get('given_id'))
    if dbDevices.length == 0
      @devices.add(deviceModel)
      if @devices.size() == 1 # first device
        @setDevice(deviceModel)

  ###JUST FOR TESTING WITHOUT A MIDI CONTROLLER###
  midi: (message) ->
    @mapProfilesView.onMidiMessage(message)
  
