class SignUpForm
  include ActiveModel::Model
  include ActiveModel::Attributes
  require 'github_user_checker'
  attribute :email, :string
  attribute :password, :string
  attribute :password_confirmation, :string
  attribute :name, :string
  validates :password, length: { minimum: 3 }
  validates :password, confirmation: true
  with_options presence: true do
    validates :email, :password, :password_confirmation, :name
  end

  validate :email_is_not_taken_by_another
  validate :github_username_exists

  def save
    return false if invalid?
    ActiveRecord::Base.transaction do
      user.save!
      Profile.create!(name: name, user: user)
    end
  rescue StandardError
    false
  end

  def user
    @user ||= User.new(email: email, password: password, password_confirmation: password_confirmation)
  @user
  end

  private

  def email_is_not_taken_by_another
    errors.add(:email, :taken, value: email) if User.exists?(email: email)
  end

  def github_username_exists
    return if name.blank?
  
    # 非ASCII文字を含む場合のチェック
    if name.match?(/[^\x00-\x7F]/)
      errors.add(:name, "サインアップに失敗しました。名前には英数字のみを使用してください。")
      return
    end
  
    # GitHub上で存在するかどうかのチェック
    unless GithubUserChecker.user_exists?(name)
      errors.add(:name, "GitHubに存在するユーザー名しか登録できません")
    end
  end

end
