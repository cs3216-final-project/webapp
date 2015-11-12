_ = require "underscore"

BaseModel = require "./base.coffee"
MappingProfile = require "./mapping.coffee"

Config = require "../config.coffee"

module.exports = BaseModel.extend
  defaults: {
    mapping_profiles: [new MappingProfile({ name: "Default" })]
  }
  parse: (response) ->
    response.mapping_profiles = response.mapping_profiles.map (mp) ->
      new MappingProfile(mp)
    response.connected = false
    return response

  getProfiles: () ->
    return @get('mapping_profiles')

  getProfileFromCid: (cid) ->
    arr = @getProfiles()
    idx = _.findIndex(arr, (item) -> return item.cid == cid)
    return arr[idx]

  addNewProfile: (name = "Untitled") ->
    mp = new MappingProfile({ name: name })
    @getProfiles().push(mp)
    return mp

  addDefaultProfile: () ->
    @addNewProfile(@defaults["mapping_profiles"][0].get('name'))

  deleteProfileByCid: (cid) ->
    mp = @getProfileFromCid(cid)
    idx = _.findIndex(@getProfiles(), (item) -> return item == mp)
    @getProfiles().splice(idx, 1)
