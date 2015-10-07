module.exports =
  isLoggedIn: ->
    localStorage.getItem('id') && localStorage.getItem('auth_token')
  loginSuccess: (response) ->
    localStorage.setItem('id', response.id)
    localStorage.setItem('auth_token', response.auth_token)
  logout: ->
    localStorage.removeItem('id')
    localStorage.removeItem('auth_token')
  getUserId: ->
    localStorage.getItem('id')
  getAuthToken: ->
    localStorage.getItem('auth_token')
  getAuthHeaders: ->
    if @isLoggedIn
      {'Authorization': 'Basic ' + btoa(@getUserId() + ':' + @getAuthToken())}
    else
      {}
