class MappingProfile < ActiveRecord::Base
  belongs_to :device
  has_many :code_maps
end
