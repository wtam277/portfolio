require 'net/http'
require 'uri'

class GithubUserChecker
  GITHUB_USER_URL = 'https://github.com/'.freeze

 def user_exists?(username)
    uri = URI.parse("https://github.com/#{username}")
    http = Net::HTTP.new(uri.host, uri.port)
    http.use_ssl = true

    #header = { 'Authorization' => 'Bearer token' }
    #uri.query = URI.encode_www_form(q: test, hoge: fuga)
    
    response = Net::HTTP.get_response(uri)
    # ステータスコードが200ならユーザーが存在
    response.code.to_i == 200
  end
end