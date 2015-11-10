$ = require "jquery"

BaseView = require "../baseView.coffee"
settingsTemplate = require "../../templates/configPage/settings.hbs"

AuthHelper = require "../../helpers/auth.coffee"

module.exports = BaseView.extend
  el: "#settings"
  template: settingsTemplate
  initialize: (options) ->
    @parent = options.parent
  render: -> #TODO Messy if else statements...
    @devices = @parent.getAllDevices()
    @currentMappingProfile = @parent.getCurrentMappingProfile()
    @currentDevice = @parent.getCurrentDevice()
    if @devices.isEmpty() && AuthHelper.isLoggedIn()# first time
      @devices.fetch(headers: AuthHelper.getAuthHeaders()).done () =>
        @parent.setAllDevices(@devices)
        if @devices.isEmpty()
          if @currentMappingProfile
            $(@el).html @template({
              devices: @devices.toJSON()
              currentMappingProfile: @currentMappingProfile.toJSON()
            })
          else
            $(@el).html @template({
              devices: @devices.toJSON()
            })
        else if @currentDevice && @currentMappingProfile
          $(@el).html @template({
            devices: @devices.toJSON()
            currentDevice: @currentDevice.toJSON()
            currentMappingProfile: @currentMappingProfile.toJSON()
          })
        else if @currentMappingProfile
          $(@el).html @template({
              devices: @devices.toJSON()
              currentMappingProfile: @currentMappingProfile.toJSON()
            })
        else
          $(@el).html @template({
            devices: @devices.toJSON()
          })
    else
      if @currentDevice && @currentMappingProfile
        $(@el).html @template({
            devices: @devices.toJSON()
            currentDevice: @currentDevice.toJSON()
            currentMappingProfile: @currentMappingProfile.toJSON()
          })
      else if @currentDevice
        $(@el).html @template({
          devices: @devices.toJSON()
          currentDevice: @currentDevice.toJSON()
        })
      else if @currentMappingProfile
        $(@el).html @template({
          devices: @devices.toJSON()
          currentMappingProfile: @currentMappingProfile.toJSON()
        })
      else
        $(@el).html @template({
          devices: @devices.toJSON()
        })
    return @
  events: ->
    "change select#device-select": "changeDevice"

  changeDevice: (e) ->
    given_id = $(e.currentTarget).val()
    device = @devices.find (model) ->
      model.get('given_id') == given_id
    @parent.setDevice(device)
