_ = require "underscore"

BaseModel = require "./base.coffee"
Config = require "../config.coffee"

module.exports = BaseModel.extend
  urlRoot: Config.apiUrl + 'mapping_profile'
  defaults: {
    code_maps: [],
    bpm: 128
  }
  setMap: (code, anim) ->
    newMapping = {code: code, animation: anim}
    currentMap = _.clone(@get("code_maps"))
    idx = currentMap.findIndex (ele, i, arr) ->
      ele.code == code
    if idx != -1
      currentMap.splice(idx, 1, newMapping)
    else
      currentMap.push(newMapping)
    @set("code_maps", currentMap)
  getMap: (code) ->
    @get("code_maps").filter((ele) ->
      ele.code == code
    )[0]
  unsetMap: (code) ->
    currentMap = _.clone(@get("code_maps"))
    idx = currentMap.findIndex (ele, i, arr) ->
      ele.code == code
    currentMap.splice(idx, 1)
    @set("code_maps", currentMap)
  setBPM: (bpm) ->
    @set("bpm", bpm)
  getBPM: () ->
    @get("bpm")

  setTitle: (title) ->
    @set("name", title)

