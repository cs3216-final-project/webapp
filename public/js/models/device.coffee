_ = require "underscore"

BaseModel = require "./base.coffee"
MappingProfile = require "./mapping.coffee"

Config = require "../config.coffee"

module.exports = BaseModel.extend
  defaults: {
    mapping_profiles: [new MappingProfile({ name: "LOL" })]
  }
  parse: (response) ->
    response.mapping_profiles = response.mapping_profiles.map (mp) ->
      new MappingProfile(mp)
    return response
