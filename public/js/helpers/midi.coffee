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
