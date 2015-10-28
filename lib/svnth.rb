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
    erb :app
  end

  get '/app' do
    redirect to('/')
  end

  post '/user/auth/?' do
    user = check_password_and_get_user(params)
    if user.nil?
      respond_as_unauthorized
    else
      return { id: user.id, auth_token: user.auth_token }.to_json
    end
  end

  post '/users/?' do
    user = User.create(JSON.parse(request.body.read))
    if user.errors.messages.empty?
      user.to_json
    else
      halt 400, user.errors.messages.to_json
    end
  end

  get '/users/:id' do
    user = authorized_user(params[:id].to_i)
    if user.nil?
      respond_as_unauthorized
    else
      content_type :json
      user.to_json
    end
  end

  get '/devices/?' do
    user = authorized_user
    if user.nil?
      respond_as_unauthorized
    end
    Device.includes(mapping_profiles: :code_maps)
      .where(user_id: user.id)
      .to_json(include: { mapping_profiles: {include: :code_maps }})
  end

  get '/devices/:id' do
    user = authorized_user
    if user.nil?
      respond_as_unauthorized
    end
    Device.includes(mapping_profiles: :code_maps)
    .find(params[:id])
    .to_json(include: { mapping_profiles: {include: :code_maps }})
  end

  post '/devices/?' do
    user = authorized_user
    if user.nil?
      respond_as_unauthorized
    end
    data = JSON.parse(request.body.read)

    device = Device.create(
      name: data["name"],
      given_id: data["given_id"]
    )
    device.set_mapping_profiles_from_array(data["mapping_profiles"])
    user.devices << device
    user.save!
    device.to_json(include: { mapping_profiles: {include: :code_maps }})
  end

  put '/devices/:id' do
    user = authorized_user
    if user.nil?
      respond_as_unauthorized
    end
    data = JSON.parse(request.body.read)
    device = Device.find(data["id"])
    device.set_mapping_profiles_from_array!(data["mapping_profiles"])
    device.save!
    device.to_json(include: { mapping_profiles: {include: :code_maps }})
  end
end
