class CreateMyProcesses < ActiveRecord::Migration
  def change
    create_table :my_processes do |t|
      t.integer :pid

      t.timestamps
    end
  end
end
