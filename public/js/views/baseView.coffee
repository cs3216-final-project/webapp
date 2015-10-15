module.exports = Backbone.View.extend
  template: null
  close: () ->
    @$el.empty()
    @unbind()
    if @onclose
      @onclose()
    return @
