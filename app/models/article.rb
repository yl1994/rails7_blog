class Article < ApplicationRecord
  validates :title, presence: true

  # after_create_commit -> { broadcast_prepend_later_to "articles" }
  # after_update_commit -> { broadcast_replace_later_to "articles" }
  # after_destroy_commit -> { broadcast_remove_later_to "articles" }

  broadcasts_to ->(article) { "articles" }, inserts_by: :prepend
  after_commit :broadcast_article_echarts, on: [:create, :update, :destroy] 

  def broadcast_article_echarts
    broadcast_replace_later_to "articles", target: "article_echarts", partial: "articles/echarts", locals: { chart_data: Article.get_echarts_data }
    # 在数据发生变化时清理缓存
    Rails.cache.delete("article_echarts_data")
  end

  def self.get_echarts_data
    Rails.cache.fetch("article_echarts_data", expires_in: 1.hour) do
      article_hash = Article.select(:kind).group(:kind).size
      categories,data = [article_hash.keys,article_hash.values]
      chart_data = { title: "文章类别数量统计", categories: categories, data: data }  
    end
  end

  def as_json(options = {})
    super(options.merge(methods: :actions_html))
  end

  def actions_html
    ApplicationController.renderer.render(
      partial: 'articles/action_bar',
      locals: { article: self }
    )
  end

  def self.ransackable_attributes(auth_object = nil)
    ["kind","title"]
  end

end
