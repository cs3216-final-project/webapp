class Device < ActiveRecord::Base
  has_many :mapping_profiles
  belongs_to :user

  def set_mapping_profiles_from_array!(mapping_profiles)
    self.mapping_profiles.destroy_all
    self.mapping_profiles = mapping_profiles.map do |mp|
      code_maps = mp["code_maps"].map do |cm|
        CodeMap.new(code: cm["code"], animation: cm["animation"])
      end
      MappingProfile.new(name: mp["name"], bpm: mp["bpm"], code_maps: code_maps)
    end
  end
end
