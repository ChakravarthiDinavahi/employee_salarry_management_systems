class CreateEmployees < ActiveRecord::Migration[7.2]
  def change
    create_table :employees do |t|
      t.string :first_name
      t.string :last_name
      t.string :job_title
      t.decimal :salary, precision: 12, scale: 2
      t.string :country
      t.string :email

      t.timestamps
    end

    add_index :employees, [ :country, :job_title ]
    add_index :employees, :salary
  end
end
