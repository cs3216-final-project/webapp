class AddBpmToMappingProfiles < ActiveRecord::Migration
  def change
  	add_column :mapping_profiles, :bpm, :integer
  end
end
