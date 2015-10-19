class CreateCodeMaps < ActiveRecord::Migration
  def change
    create_table :code_maps do |t|
      t.belongs_to :mapping_profile, index: true
      t.integer :code
      t.string :animation
    end
  end
end
