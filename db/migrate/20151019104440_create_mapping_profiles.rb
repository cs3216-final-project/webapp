class CreateMappingProfiles < ActiveRecord::Migration
  def change
    create_table :mapping_profiles do |t|
      t.belongs_to :device, index: true
      t.string :name
    end
  end
end
