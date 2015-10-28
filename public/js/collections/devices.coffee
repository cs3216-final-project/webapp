BaseCollection = require "./base.coffee"
Config = require "../config.coffee"
Device = require "../models/device.coffee"
module.exports = BaseCollection.extend
  model: Device
  url: Config.apiUrl + 'devices'
