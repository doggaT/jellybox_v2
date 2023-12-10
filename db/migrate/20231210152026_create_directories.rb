class CreateDirectories < ActiveRecord::Migration[7.0]
  def change
    create_table :directories do |t|
      t.string :name, unique: true
      t.integer :parent_id
      t.timestamps default: -> { 'CURRENT_TIMESTAMP' }
    end
  end
end
