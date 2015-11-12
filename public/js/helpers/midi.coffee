module.exports =

  # This method is a giant hack until we figure out the MIDI spec
  isValid: (data) ->
    return false if data.length < 3
    if data[0] == 144 # nanoKEY2
      return true
    if data[0] == 153 &&  data[2] != 0 # launchkey and yamaha
      return true

    # this is a knob. Disabling this until we figure what to do with it
    # if data[0] == 176
    #   return true

    return false

  initMidiDeviceConnection: () ->
    self = @
    if navigator.requestMIDIAccess
      navigator.requestMIDIAccess(sysex: false).then(
        @onMIDISuccess.bind(self)
        @onMIDIFailure.bind(self)
      )
    else
      alert 'No MIDI support in your browser.'

  onMIDISuccess: (midiAccess) ->
    inputs = midiAccess.inputs.values()
    input = inputs.next()
    devices = []

    while input and !input.done
      input.value.onmidimessage = @onMidiMessage.bind(@)
      console.log("Detected Device")
      console.log(input.value)
      global.SvnthApp.views.configPage.addDevice(input.value)
      input = inputs.next()


  onMIDIFailure: (e) ->
    console.err("No access to MIDI devices or your browser doesn't support WebMIDI API. Please use WebMIDIAPIShim " + e);

  onMidiMessage: (message) ->
    data = message.data
    console.log(data)
    return unless @isValid(data)
    code = data[1]
    global.SvnthApp.views.configPage.triggerCode(code)
