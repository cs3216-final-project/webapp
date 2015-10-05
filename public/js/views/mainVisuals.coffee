$ = require "jquery"
Two = require "twojs-browserify"

BaseView = require "./baseView.coffee"
mainVisualsTemplate = require "../templates/mainVisuals.hbs"
midiTriggersTemplate = require "../templates/midiTriggers.hbs"

module.exports = BaseView.extend
  el: "#main-wrapper"
  mainVisualsTemplate: mainVisualsTemplate
  midiTriggersTemplate: midiTriggersTemplate
  initialize: ->
    @two = new Two(fullscreen: false)
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
    @playAnimation()
    #alert("Midi Signal received: " + data[2]) # note

  playAnimation: () ->


    bg1 = @two.makeRectangle(@two.width / 2, @two.height / 2, @two.width, @two.height)

    #draw rectangle convering entire frame
    bg1.fill = '#42e8fe'
    bg1.noStroke()
    @two.bind('update', (frameCount) ->
      if bg1.opacity > 0
        bg1.opacity -= 0.1
      return
    ).play()

    callback = ->
      @two.remove bg1
      @two.pause()

    setTimeout callback.bind(@), 300
