_ = require "underscore"

BaseModel = require "./base.coffee"
Config = require "../config.coffee"
module.exports = BaseModel.extend
  urlRoot: Config.apiUrl + 'mapping'
  defaults: {
    maps: []
  }
  setMap: (code, anim) ->
    newMapping = {code: code, anim: anim}
    currentMap = _.clone(@get("maps"))
    idx = currentMap.findIndex (ele, i, arr) ->
      ele.code == code
    if idx != -1
      currentMap.splice(idx, 1, newMapping)
    else
      currentMap.push(newMapping)
    @set("maps", currentMap)
  getMap: (code) ->
    @get("maps").filter((ele) ->
      ele.code == code
    )[0]
  unsetMap: (code) ->
    currentMap = _.clone(@get("maps"))
    idx = currentMap.findIndex (ele, i, arr) ->
      ele.code == code
    currentMap.splice(idx, 1)
    @set("maps", currentMap)
