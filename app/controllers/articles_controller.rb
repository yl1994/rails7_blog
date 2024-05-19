class ArticlesController < ApplicationController
  before_action :find_me, only: [:edit,:update,:destroy,:change_published]

  before_action :get_echarts, only: [:index]
  
  def index
    @q = Article.order(id: :desc).ransack(params[:q])
    @articles =  @q.result.page(params[:page]).per(params[:per])
    respond_to do |format|
      format.html
      format.json do 
        render json: {
          data: @articles,
          draw: params[:draw].to_i,
          recordsTotal: Article.count,
          recordsFiltered: @articles.total_count,
        } 
      end
    end
  end

  def new
    @article = Article.new
  end

  def create
    @article = Article.new(article_params)
    get_echarts
    if @article.save
      respond_to do |f|
        f.html {redirect_to articles_path,notice: "创建成功"}
        f.turbo_stream { flash.now[:notice] = "创建成功" }
      end
    else
      flash.now[:error] = "创建失败"
      render :new, status: 422
    end
  end

  def edit
    
  end

  def update
    if @article.update(article_params)
      get_echarts
      respond_to do |f|
        f.html {redirect_to articles_path,notice: "更新成功"}
        f.turbo_stream  { flash.now[:notice] = "更新成功" }
      end
    else
      flash.now[:error] = "更新失败"
      render :edit, status: 422
    end
  end

  def destroy
    @article.destroy if @article
    redirect_to articles_path,notice: "删除成功"
  end

  def change_published
    @article.toggle! :published
    redirect_to articles_path,notice: "操作成功"
  end

  private
  def find_me
    @article = Article.find(params[:id])
  end

  def get_echarts
    @chart_data = Article.get_echarts_data
  end

  def article_params
    params.require(:article).permit(:title,:kind,:content)
  end
end
