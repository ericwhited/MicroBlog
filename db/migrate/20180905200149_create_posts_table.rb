class CreatePostsTable < ActiveRecord::Migration[5.2]
  def change
    create_table :posts do |t|
      t.text :body
      t.datetime :posted_at, default: "now()"
      t.integer :user_id
    end
  end
end
