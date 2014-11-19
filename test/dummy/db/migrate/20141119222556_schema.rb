class Schema < ActiveRecord::Migration
  def change
    create_table :projects do |t|
      t.string :name
    end

    create_table :issues do |t|
      t.belongs_to :project
      t.string :title
      t.string :body
    end

    create_table :comments do |t|
      t.belongs_to :issue
      t.string :title
      t.string :body
    end
  end
end
