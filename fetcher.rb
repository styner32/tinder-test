require 'http'
require 'json'
require 'yaml'
require './config'

def fetch(token)
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

  res = HTTP.get("https://api.gotinder.com/user/recs", options)
  return JSON.parse(res.body)["results"]
end
