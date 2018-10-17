class CreateBusinessServices < ActiveRecord::Migration
  def change
    create_table :services do |t|
      t.string :name, {null:false}
      t.text :description
      t.text :notes
      t.integer :creator_id, {null:false}

      t.timestamps null: false
    end

    create_table :businesses do |t|
      t.string :name, {null: false}
      t.text :description
      t.text :notes

      t.timestamps null: false
    end
   
    create_table :business_services do |t|
      t.references :service, {index: true, foreign_key: true, null:false}
      t.references :business, {index: true, foreign_key: true, null:false}
      t.integer :priority, {null:false, default:5}
      t.integer :creator_id, {null:false}

      t.timestamps null: false
    end

    add_index :services, :creator_id
    add_index :businesses, :name
    add_index :business_services, [:service_id, :business_id], unique:true
  end
end
