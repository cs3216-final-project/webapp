class App
  helpers do
    def protected!
      return if !!authorized_user
      respond_as_unauthorized
    end

    def authorized_user
      @auth ||=  Rack::Auth::Basic::Request.new(request.env)
      if @auth.provided? && @auth.basic? && @auth.credentials
        return check_token_and_get_user(
          username: @auth.credentials[0],
          auth_token: @auth.credentials[1]
        )
      else
        return nil
      end
    end

    def check_token_and_get_user(params)
      user = User.where(username: params[:username]).last
      if user && user.valid_token?(params[:auth_token])
        return user
      end
      return nil
    end

    def check_password_and_get_user(params)
      user = User.where(
        username: params[:username],
      ).last
      if user && user.password == params[:password]
        return user
      end
      return nil
    end

    def respond_as_unauthorized
      headers['WWW-Authenticate'] = 'Basic realm="Restricted Area"'
      halt 401, "Not authorized\n"
    end
  end

  get '/' do
    erb :index
  end

  get '/app' do
    erb :app
  end
end
