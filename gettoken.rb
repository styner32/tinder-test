require 'http'
require 'json'
require './config'

$facebook_info = {
  "locale": "en-SG",
  "force_refresh": false,
  "facebook_token": $conf['facebook_token'],
  "facebook_id": $conf['facebook_id']
}

def gettoken()
  res = HTTP.post("https://api.gotinder.com/auth", json: $facebook_info)
  return JSON.parse(res.body)
end
