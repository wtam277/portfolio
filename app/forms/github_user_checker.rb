require 'net/http'
require 'uri'

class GithubUserChecker
  # クラスメソッドとして定義
  def self.user_exists?(username)
    uri = URI.parse("https://github.com/#{username}")
    
    begin
      # SSLを有効にするための設定
      http = Net::HTTP.new(uri.host, uri.port)
      http.use_ssl = true
      
      # Net::HTTP.get_response でレスポンスを取得
      response = http.get(uri)

      # ステータスコードが200ならユーザーが存在する
      response.code.to_i == 200
    rescue StandardError
      # エラーハンドリング
      false
    end
  end
end