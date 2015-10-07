class App
  helpers do

    # optional param `id` checks if the authorized user is the same as the user
    # whose details are being fetched
    def authorized_user(id = nil)
      @auth ||=  Rack::Auth::Basic::Request.new(request.env)
      if @auth.provided? && @auth.basic? && @auth.credentials
        user = check_token_and_get_user(
          id: @auth.credentials[0],
          auth_token: @auth.credentials[1]
        )
        id.nil? ? user : (user && user.id === id ? user : nil)
      else
        nil
      end
    end

    def check_token_and_get_user(params)
      user = User.where(id: params[:id]).last
      if user && user.valid_token?(params[:auth_token])
        user
      else
        nil
      end
    end

    def check_password_and_get_user(params)
      user = User.where(
        email: params[:email],
      ).last
      if user && user.password == params[:password]
        user
      else
        nil
      end
    end

    def respond_as_unauthorized
      # headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
      halt 401, "Not authorized\n"
    end
  end

  get '/' do
    erb :index
  end

  get '/app' do
    erb :app
  end

  post '/user/auth' do
    user = check_password_and_get_user(params)
    if user.nil?
      respond_as_unauthorized
    else
      return { id: user.id, auth_token: user.auth_token }.to_json
    end
  end

  post '/user' do
    User.first_or_create(params)
  end

  get '/user/:id' do
    user = authorized_user(params[:id].to_i)
    if user.nil?
      respond_as_unauthorized
    else
      content_type :json
      user.to_json
    end
  end
end
