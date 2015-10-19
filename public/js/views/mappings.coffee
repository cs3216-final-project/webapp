$ = require "jquery"
_ = require "underscore"

BaseView = require "./baseView.coffee"
mappingsTemplate = require "../templates/mappings.hbs"
mapTemplate = require "../templates/map.hbs"

Device = require "../models/device.coffee"
MappingProfile = require "../models/mapping.coffee"

AuthHelper = require "../helpers/auth.coffee"
Animations = require "../helpers/animations.coffee"
MidiHelper = require "../helpers/midi.coffee"

module.exports = BaseView.extend
  el: '#mappings-config'
  mappingsTemplate: mappingsTemplate
  mapTemplate: mapTemplate
  initialize: ->
    @devices = global.SvnthApp.collections.devices
    @animArr = Animations.getAll()
    @currentBPM = 128

  render: ->
    if @devices.isEmpty() # first time
      @devices.fetch(headers: AuthHelper.getAuthHeaders()).done () =>
        console.log(@devices)
        if @devices.isEmpty()
          $(@el).html @mappingsTemplate({
            animations: @animArr
            devices: @devices.toJSON()
            currentBPM: @currentBPM
          })
        else
          @currentDevice = @devices.first()
          @currentMappingProfile = @currentDevice.get('mapping_profiles')[0]

          $(@el).html @mappingsTemplate({
            animations: @animArr
            devices: @devices.toJSON()
            currentDevice: @currentDevice.toJSON()
            currentMappingProfile: @currentMappingProfile.toJSON()
            currentBPM: @currentBPM
          })
        @initMidiDeviceConnection()
    else
      return unless @currentDevice? and @currentMappingProfile?
      $(@el).html @mappingsTemplate({
        animations: @animArr
        devices: @devices.toJSON()
        currentDevice: @currentDevice.toJSON()
        currentMappingProfile: @currentMappingProfile.toJSON()
        currentBPM: @currentBPM
      })
    return @
  events:
    "change select#device-select": "changeDevice"
    "change select.animation-select": "changeAnimation"
    "click .device-save-btn": "saveDevice"
    "click .trigger-map": "triggerMap"
    "click .remove-map": "removeMap"
    "change .bpm-input": "setBPM"

  setBPM: (e) ->
    bpm = $(e.currentTarget).find("input").val()
    if (bpm <= 0 || bpm > 200)
      @currentBPM = 128
    else
      @currentBPM = bpm
    @render()

  saveDevice: (e) ->
    @currentDevice.save({}, { headers: AuthHelper.getAuthHeaders() }).done () ->
      console.log("saved")

  setDevice: (device) ->
    @currentDevice = device
    @currentMappingProfile = _.first(@currentDevice.get('mapping_profiles'))
    @render()

  changeDevice: (e) ->
    given_id = $(e.currentTarget).val()
    device = @devices.find (model) ->
      model.get('given_id') == given_id
    @setDevice(device)

  addDevice: (device) ->
    deviceModel = new Device({ name: device.name, given_id: device.id })
    dbDevices = (item for item in @devices.models when item.get('given_id') == deviceModel.get('given_id'))
    if dbDevices.length == 0
      @devices.add(deviceModel)
      if @devices.size() == 1 # first device
        @setDevice(deviceModel)
    @render()

  removeMap: (e) ->
    code = $(e.currentTarget).data('midicode')
    @currentMappingProfile.unsetMap(code)
    @render()

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
      @addDevice(input.value)
      input = inputs.next()

  onMIDIFailure: (e) ->
    console.err("No access to MIDI devices or your browser doesn't support WebMIDI API. Please use WebMIDIAPIShim " + e);

  onMidiMessage: (message) ->
    data = message.data
    console.log(data)
    return unless MidiHelper.isValid(data)
    code = data[1]

    map = @currentMappingProfile.getMap(code)

    if !map
      @currentMappingProfile.setMap(code, @animArr[0].key)
      map = @currentMappingProfile.getMap(code)
      @render()

    @playAnimation(map)

  changeAnimation: (e) ->
    ele = $(e.currentTarget)
    animId = ele.val()
    return if animId == ""
    code = ele.find(":selected").data('midicode')
    @currentMappingProfile.setMap(code, animId)
    @playAnimation(@currentMappingProfile.getMap(code))

  triggerMap: (e) ->
    code = $(e.currentTarget).data('midicode')
    @playAnimation(@currentMappingProfile.getMap(code))

  playAnimation: (map) ->
    # TODO: make this a pub-sub system
    global.SvnthApp.views.mainVisuals.playAnimation(map, @currentBPM)
