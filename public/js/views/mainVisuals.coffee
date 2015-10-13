$ = require "jquery"
Two = require "twojs-browserify"

BaseView = require "./baseView.coffee"
Animate = require "../helpers/animations.coffee"
Keycode = require "../helpers/keycode.coffee"
mainVisualsTemplate = require "../templates/mainVisuals.hbs"
visualsConfigTemplate = require "../templates/visualsConfig.hbs"
#midiTriggersTemplate = require "../templates/midiTriggers.hbs"

module.exports = BaseView.extend
  el: "#main-wrapper"
  visualsConfigTemplate: visualsConfigTemplate
  mainVisualsTemplate: mainVisualsTemplate
  #midiTriggersTemplate: midiTriggersTemplate
  initialize: ->
    @two = new Two(fullscreen: false)
    @isKeymapEnabled = false
    @keymap = {}
    #TEMPORARY SET OF ANIMATIONS
    @animArr = {blue: "Blue Flash", green: "Green Lines", "orange": "Orange Circle"}
    _.bindAll(@, 'handleKeyboardTrigger');
    $(document).on('keydown', @handleKeyboardTrigger)
    Keycode.setDict()
  render: ->
    #$(@el).append @midiTriggersTemplate()
    $(@el).append @visualsConfigTemplate()
    $(@el).append @mainVisualsTemplate()
    vis = document.getElementById('visual-space')
    @two.appendTo vis
    @connectToMidiDevice()
    @initButtons()
    return @
  events:
    #"click .midi-triggers .trigger": "handleButtonTrigger"
    "keydown #txt-char": "handleKeyboardConfig"
    "click .anim-btn": "handleButtonClick"
  remove: ->
    $(document).off('keydown', @handleKeyboardTrigger)

  handleKeyboardConfig: (e) ->
    e.preventDefault()
    code = e.keyCode || e.which
    textBox = e.target
    name = Keycode.getName(code)
    textBox.value = name
    @unsetAllButtons()
    if (@hasKey(name))
      anim = @getValue(name)
      @setButton(anim)
      @playAnimation(anim)

  handleKeyboardTrigger: (e) ->
    if (!$("#config-menu").hasClass("in"))
      e.preventDefault()
      code = e.keyCode || e.which
      console.log(code)
      name = Keycode.getName(code)
      if (@hasKey(name))
        anim = @getValue(name)
        @playAnimation(anim)

  handleButtonClick: (e) ->
    if ($('#txt-char').val() == "")
      @playAnimation(e.target.id)
    else
      if ($("#"+e.target.id).hasClass("disabled"))
        @playAnimation(e.target.id)
      else
        @chooseAnimation(e)

  chooseAnimation: (e) ->
    key = $('#txt-char').val()
    name = $("#"+e.target.id).html()
    value = e.target.id
    if @hasKey(key)
      @unsetButton(@getValue(key))
    @setKey(key, value)
    console.log(@keymap)
    @setButton(e.target.id)
    @playAnimation(value)
    $('#spn-confirm').fadeIn(200).delay(2000).html("Key "+key+" is set as "+name).fadeOut(200)

  # handleButtonTrigger: (e) ->
  #   @onMidiMessage(
  #     -1 # TODO: remove hardcoding.
  #   )

  toggleKeyboardInterface: (e) ->
    if (@isKeymapEnabled == true)
      e.target.innerText = "Configure Keyboard Animation"
      @isKeymapEnabled = false
      $('.keyboard-config').hide()
    else
      e.target.innerText = "Close Configurations"
      @isKeymapEnabled = true
      $('.keyboard-config').show()
      $('#txt-char').val("")
      $('.options').hide()

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
    data = message
    console.log(data)
    Animate.generateAnimation(@two, @)

  initButtons: () ->
      $.each @animArr, (i, v) ->
        $('#animations-list').append '<button type="button" class="list-group-item anim-btn" id="' + i + '">' + v + '</button>'

  setButton: (button) ->
    $("#"+button).addClass("active disabled")

  unsetButton: (button) ->
    $("#"+button).removeClass("active disabled")

  unsetAllButtons: () ->
    $.each @animArr, (i, v) ->
      elem = $("#"+i)
      if (elem.hasClass("active disabled"))
        elem.removeClass("active disabled")

  setKey: (key, value) ->
    @keymap[key] = value

  getValue: (key) ->
    if (@hasKey(key))
      @keymap[key]

  hasKey: (key) ->
    if (@keymap.hasOwnProperty(key))
      true
    else
      false

  playAnimation: (anim) ->
    switch anim
      when "blue"
        Animate.rectflash(@two, @)
      when "orange"
        Animate.circleslide(@two, @)
      when "green"
        Animate.linerandom(@two, @)
