class CreateItems < ActiveRecord::Migration
  def change
    create_table :items do |t|
      t.text :company_number
      t.text :company_name
      t.text :company_type
      t.text :member_full_name
      t.text :member_first_name
      t.text :member_last_name
      t.text :member_title
      t.text :member_is_admin
      t.text :member_phone
      t.text :member_number
      t.text :address
      t.text :city
      t.text :state
      t.text :country
      t.text :phone
      t.text :email
      t.text :website
      t.text :regions
      t.text :industries
      t.text :about
      
      t.text   :locations
      t.integer :page
      t.text :url
      t.text   :html

      t.timestamps
    end
  end
end
