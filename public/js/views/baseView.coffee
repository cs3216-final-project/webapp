module.exports = Backbone.View.extend
  close: () ->
    @$el.empty()
    @unbind()
    if @onclose
      @onclose()
    return @
