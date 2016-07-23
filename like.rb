require 'http'
require 'json'
require 'yaml'
require './config'

def like(token, id, content_hash, user_traveling)
  options = HTTP::Options.new(headers: {
    "Authorization" => "Token token \"#{token}\"",
    "x-client-version" => $conf['client_version'],
    "app-version" => $conf['app_version'],
    "Proxy-Connection" => "keep-alive",
    "platform" => "ios",
    "Accept-Language" => "en-SG;q=1",
    "Accept" => "*/*",
    "User-Agent" => $conf['user_agent'],
    "Connection" => "keepkeep-alive",
    "X-Auth-Token" => token,
    "os_version" => "90000300002"
  })

  url = "https://api.gotinder.com/like/#{id}?content_hash=#{content_hash}"
  url += "&user_traveling=1" if user_traveling

  res = HTTP.post(url, options)
  return JSON.parse(res.body)
end
