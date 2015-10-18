class Device < ActiveRecord::Base
  has_many :mappings
  belongs_to :user
end
