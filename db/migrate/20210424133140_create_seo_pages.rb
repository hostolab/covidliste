class CreateSeoPages < ActiveRecord::Migration[6.1]
  def change
    create_table :seo_pages do |t|
      t.string :status
      t.string :slug
      t.string :title, null: false
      t.boolean :indexable, default: false, null: false
      t.boolean :crawlable, default: false, null: false
      t.string :seo_title
      t.string :seo_description
      t.text :body
      t.timestamps
      t.check_constraint("status IN ('draft', 'review', 'ready', 'online', 'archive')", name: "status_is_a_known_status")
    end

    add_index :seo_pages, :slug, unique: true
  end
end
