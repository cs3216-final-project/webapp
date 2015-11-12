$ = require "jquery"

BaseView = require "../baseView.coffee"
midiSettingsTemplate = require "../../templates/configPage/midiSettings.hbs"

AuthHelper = require "../../helpers/auth.coffee"
MidiHelper = require "../../helpers/midi.coffee"

module.exports = BaseView.extend
  el: "#settings"
  template: midiSettingsTemplate
  initialize: (options) ->
    @parent = global.SvnthApp.views.configPage
  render: ->
    @devices = @parent.getAllDevices()
    @currentMappingProfile = @parent.getCurrentMappingProfile()
    @currentDevice = @parent.getCurrentDevice()

    if @devices.isEmpty()
      @devices.fetch(headers: AuthHelper.getAuthHeaders()).done () =>
        @parent.setAllDevices(@devices)
        @renderCurrentState()
        @initMidiDeviceConnection()
    else
      @renderCurrentState()

    return @
  events: ->
    "change select#device-select": "changeDevice"

  renderCurrentState: ->
    $(@el).html @template({
      devices: if @devices? then @devices.toJSON() else []
      currentDevice: if @currentDevice? then @currentDevice.toJSON() else null
      currentMappingProfile: if @currentMappingProfile? then @currentMappingProfile.toJSON() else null
    })

  initMidiDeviceConnection : ->
    MidiHelper.initMidiDeviceConnection()

  changeDevice: (e) ->
    given_id = $(e.currentTarget).val()
    @devices = @parent.getAllDevices()
    device = @devices.find (model) ->
      model.get('given_id') == given_id
    @parent.setDevice(device)
    @render()
