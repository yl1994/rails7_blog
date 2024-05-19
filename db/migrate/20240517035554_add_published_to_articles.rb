class AddPublishedToArticles < ActiveRecord::Migration[7.1]
  def change
    add_column :articles, :published, :boolean, default: true, comment: "是否发布"
  end
end
