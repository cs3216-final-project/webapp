$ = require "jquery"
Two = require "twojs-browserify"
Animate = require "./myAnimations.coffee"

BaseView = require "./baseView.coffee"
mainVisualsTemplate = require "../templates/mainVisuals.hbs"
midiTriggersTemplate = require "../templates/midiTriggers.hbs"

module.exports = BaseView.extend
  el: "#main-wrapper"
  mainVisualsTemplate: mainVisualsTemplate
  midiTriggersTemplate: midiTriggersTemplate
  initialize: ->
    @animate = new Animate()
    @two = new Two(fullscreen: false)
    #@loadScript()
  render: ->
    $(@el).append @midiTriggersTemplate()
    $(@el).append @mainVisualsTemplate()
    vis = document.getElementById('divspace')
    @two.appendTo vis
    @connectToMidiDevice()
    return @
  events:
    "click .midi-triggers .btn": "handleKeyboardTrigger"

  handleKeyboardTrigger: (e) ->
    @onMidiMessage(
      data: [144, 63, 100] # TODO: remove hardcoding.
    )

  #iniialiazeTwo: (canvas) ->

  loadScript: () ->
    $.getScript('../helpers/myAnimations.coffee', function: () ->
      alert 'Script loaded but not necessarily executed.'
    );

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
    $('.midi-device-detail').html("Connected: " + mainDevice.name)

  onMIDIFailure: (e) ->
    console.err("No access to MIDI devices or your browser doesn't support WebMIDI API. Please use WebMIDIAPIShim " + e);

  onMidiMessage: (message) ->
    data = message.data
    console.log(data)
    @animate.generateAnimation(@two, @)
    #alert("Midi Signal received: " + data[2]) # note
