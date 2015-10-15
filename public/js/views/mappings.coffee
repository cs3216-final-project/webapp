$ = require "jquery"

BaseView = require "./baseView.coffee"
mappingsTemplate = require "../templates/mappings.hbs"
mapTemplate = require "../templates/map.hbs"

Mapping = require "../models/mapping.coffee"
Animations = require "../helpers/animations.coffee"
MidiHelper = require "../helpers/midi.coffee"

module.exports = BaseView.extend
  el: '#mappings-config'
  mappingsTemplate: mappingsTemplate
  mapTemplate: mapTemplate
  initialize: ->
    @midiMap = new Mapping({ name: "Test Mapping" })
    @animArr = Animations.getAll()
    @midiMap.on('change', @render, @)
  render: ->
    @connectToMidiDevice()
    $(@el).html @mappingsTemplate({ animations: @animArr, midiMap: @midiMap.toJSON() })
    return @
  events:
    "change select.animation-select": "changeAnimation"
    "click .trigger-map": "triggerMap"
    "click .remove-map": "removeMap"

  triggerMap: (e) ->
    code = $(e.currentTarget).data('midicode')
    @playAnimation(@midiMap.getMap(code))

  removeMap: (e) ->
    code = $(e.currentTarget).data('midicode')
    @midiMap.unsetMap(code)

  connectToMidiDevice: () ->
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
    devices = []
    input = inputs.next()

    while input and !input.done
      input.value.onmidimessage = @onMidiMessage.bind(@)
      devices.push input.value
      input = inputs.next()

    mainDevice = devices[0] # TODO: loop and let user choose device

    # TODO: Put this in a better place
    if mainDevice
      $('.midi-device-detail').html(mainDevice.name)

  onMIDIFailure: (e) ->
    console.err("No access to MIDI devices or your browser doesn't support WebMIDI API. Please use WebMIDIAPIShim " + e);

  onMidiMessage: (message) ->
    data = message.data
    console.log(data)
    return unless MidiHelper.isValid(data)
    code = data[1]

    map = @midiMap.getMap(code)

    if !map
      @midiMap.setMap(code, @animArr[0].key)
      map = @midiMap.getMap(code)
      # $(@el).find("#map-elements").append mapTemplate({ code: code, map: map, animations: @animArr })

    @playAnimation(map)

  changeAnimation: (e) ->
    ele = $(e.currentTarget)
    animId = ele.val()
    code = ele.find(":selected").data('midicode')
    @midiMap.setMap(code, animId)
    @playAnimation(@midiMap.getMap(code))

  playAnimation: (map) ->
    # TODO: make this a pub-sub system
    global.SvnthApp.views.mainVisuals.playAnimation(map.anim)
