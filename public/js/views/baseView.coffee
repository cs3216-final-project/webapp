module.exports = Backbone.View.extend
  close: () ->
    @$el.empty()
    @unbind()
    if @onclose
      @onclose()
    return @
  assign : (view, selector) ->
    view.setElement(@$(selector)).render()
