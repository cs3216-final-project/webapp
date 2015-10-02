BaseModel = require "./base.coffee"
Config = require "../config.coffee"
module.exports = BaseModel.extend
  urlRoot: Config.apiUrl + 'visuals'