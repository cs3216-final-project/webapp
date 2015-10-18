class User < ActiveRecord::Base
  has_many :devices

  include BCrypt
  has_secure_token :auth_token
  validates_presence_of :email, :password

  def create
    @user = User.new(params[:user])
    @user.password = params[:password]
    @user.save!
  end

  def password
    @password ||= Password.new(password_hash)
  end

  def password=(new_password)
    @password = Password.create(new_password)
    self.password_hash = @password
  end

  def valid_token?(token)
    auth_token == token
  end

  def to_json(options={})
    options[:except] ||= [:password_hash]
    super(options)
  end
end
