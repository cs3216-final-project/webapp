module.exports = (Handlebars) ->
  return {
    select: (value, options) ->
      $el = $('<select />').html(options.fn(this))
      $el.find('[value="' + value + '"]').attr({'selected':'selected'})
      $el.html()

    ifEquals: (a, b, options) ->
      return options.fn(@) if a == b
      return options.inverse(@) if a != b
  }
