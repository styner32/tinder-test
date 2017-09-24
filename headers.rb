require './config'

def get_headers(token)
  {
    "Authorization" => "Token token=\"#{token}\"",
    "x-client-version" => $conf['client_version'],
    "app-version" => $conf['app_version'],
    "x-experiment-id" => "bfced51",
    "Accept-Language" => "en-SG;q=1, zh-Hans-SG;q=0.9",
    "platform" => "ios",
    "Accept" => "*/*",
    "install-id" => "A927C19E-F74C-4FF6-8AAF-A4963DE6A32B",
    "User-Agent" => $conf['user_agent'],
    "X-Auth-Token" => token,
    "Accept-Encoding": "deflate, gzip"
  }
end
