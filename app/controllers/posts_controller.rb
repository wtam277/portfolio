class PostsController < ApplicationController
  before_action :require_login, only: %i[new create]
  before_action :set_q, only:[:index,:search]
  def index
    q= Post.ransack({ combinator: 'and', groupings: grouping_hash })
    @posts = @q.result(distinct: true).includes(:tags, :user).order(created_at: :desc).page(params[:page]).per(10)
  end

  def new
    @post = Post.new
    @q = Post.ransack(params[:q])
  end

  def create
    @post = current_user.posts.new(post_params)
  #新規ページ
    tag_names =params[:tag_name].split(",")
    tags = tag_names.map { |tag_name| Tag.find_or_initialize_by(name: tag_name) }

    tags.each do |tag|
      if tag.invalid?
        @tag_name = params[:tag_name]
        @post.errors.add(:tags, tag.errors.full_messages.join("\n"))
        return render :edit, status: :unprocessable_entity
      end
    end
    @post.tags = tags

    if @post.save
      redirect_to post_path(@post), success: 'ポストを作成しました'
    else
      @tag_name = params[:tag_name]
      flash.now[:danger] = 'ポストを作成できませんでした'
      render :new
    end
    
  end

  def show
    @post = Post.find(params[:id])
    @comment = Comment.new
    @post = Post.find(params[:id])
    @q = Post.ransack(params[:q])
  end

  def edit
    @post = current_user.posts.find(params[:id])
    @tag_name = @post.tags.pluck(:name).join(",")
    @post = Post.find(params[:id])
    @q = Post.ransack(params[:q])
  end

  def update
    @post = current_user.posts.find(params[:id])
    # 1. カンマ区切りの文字列を配列にする
    tag_names = params[:tag_name].split(",")
    # 2. タグ名の配列をタグの配列にする
    tags = tag_names.map { |tag_name| Tag.find_or_create_by(name: tag_name) }
    # 3. タグのバリデーションを行い、バリデーションエラーがあればPostのエラーに加える
    tags.each do |tag|
      if tag.invalid?
        @tag_name = params[:tag_name]
        @post.errors.add(:tags, tag.errors.full_messages.join("\n"))
        return render :edit, status: :unprocessable_entity
      end
    end
    if @post.update(post_params) && @post.update!(tags: tags)
      redirect_to post_path(@post), success: 'ポストを更新しました'
    else
      flash.now[:danger] = 'ポストを更新できませんでした'
      @tag_name = params[:tag_name]
      render :edit
    end
  end

  def destroy
    @post = current_user.posts.find(params[:id])
    @post.destroy!
    redirect_to posts_path, success: 'ポストを削除しました'
  end

  private

  def post_params
    params.require(:post).permit(:title, :body)
  end

  def set_q
    @q = Post.ransack(params[:q])
  end
end

def grouping_hash
  return [] unless params[:q] # params[:q]
  [
    { title_or_body_cont: params[:q][:title_or_body_cont] },
    { body_cont: params[:q][:body_cont] },
    { user_profile_name_cont: params[:q][:user_profile_name_cont]}
  ].reject(&:empty?) # 空のハッシュを除外
end