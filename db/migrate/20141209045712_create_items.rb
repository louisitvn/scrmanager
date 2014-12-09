class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.string :company_number
      t.string :company_name
      t.string :company_type
      t.string :member_full_name
      t.string :member_first_name
      t.string :member_last_name
      t.string :member_title
      t.string :member_is_admin
      t.string :member_phone
      t.string :member_number
      t.string :address
      t.string :city
      t.string :state
      t.string :country
      t.string :phone
      t.string :email
      t.string :website
      t.string :regions
      t.string :industries
      t.string :about
      
      t.text   :locations
      t.integer :page
      t.string :url
      t.text   :html

      t.timestamps
    end
  end
end
