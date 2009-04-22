class CreateOptions < ActiveRecord::Migration
  def self.up
    create_table :options do |t|
      t.string :label
      t.string :code
      t.boolean :template
      t.text :procedure
      t.datetime :expired_at

      t.timestamps
    end
  end

  def self.down
    drop_table :options
  end
end
