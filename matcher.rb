require 'yaml'
require 'http'
require 'json'

class Matcher
  DEFAULT_CONFIG_PATH = 'config.yml'
  API_HOST = 'https://api.gotinder.com'

  def initialize(config_path = DEFAULT_CONFIG_PATH)
    @config = YAML::load_file(config_path)
    @token = nil
    @logger = Logger.new(STDOUT)
  end

  def authenticate
    facebook_info = {
      "token": @config['facebook_token'],
      "id": @config['facebook_id'],
      "client_version": @config['client_version']
    }

    res = HTTP.post("#{API_HOST}/v2/auth/login/facebook",
      json: facebook_info,
      headers: get_auth_headers)

    j = JSON.parse(res.body)
    if j["data"]["api_token"]
      puts "succesfully authenticate: #{j["data"]["api_token"]}"
    else
      puts "failed to authenticate: #{j}"
    end

    @token = j["data"]["api_token"]
  end

  def fetch
    options = HTTP::Options.new(headers: get_headers)
    res = HTTP.get("#{API_HOST}/v2/recs/core?fast_match=1&locale=en-SG", options)
    result = JSON.parse(res.body)
    puts result
    return result["data"]["results"]
  end

  def like(id, content_hash, user_traveling)
    options = HTTP::Options.new(headers: get_headers)
    url = "#{API_HOST}/like/#{id}?content_hash=#{content_hash}"
    url += "&user_traveling=1" if user_traveling

    res = HTTP.post(url, options)
    return JSON.parse(res.body)
  end

  def pass(id, content_hash, user_traveling)
    options = HTTP::Options.new(headers: get_headers)
    url = "#{API_HOST}/pass/#{id}?content_hash=#{content_hash}"
    url += "&user_traveling=1" if user_traveling

    res = HTTP.post(url, options)
    return JSON.parse(res.body)
  end

  @private
  def get_headers
    @_headers ||= {
      "Authorization" => "Token token=\"#{@token}\"",
      "x-client-version" => 80025,
      "app-version" => 2061,
      "x-experiment-id" => "bfced51",
      "Accept-Language" => "en-SG;q=1, zh-Hans-SG;q=0.9",
      "platform" => "ios",
      "Accept" => "*/*",
      "install-id" => "A927C19E-F74C-4FF6-8AAF-A4963DE6A32B",
      "User-Agent" => 'Tinder/8.0.0 (iPhone; iOS 10.3.3; Scale/2.00)',
      "X-Auth-Token" => @token,
    }
  end

  def get_auth_headers
    @_auth_headers ||= {
      "x-client-version" => 80025,
      "app-version" => 2061,
      "x-experiment-id" => "bfced51",
      "Accept-Language" => "en-SG;q=1, zh-Hans-SG;q=0.9",
      "platform" => "ios",
      "Accept" => "*/*",
      "install-id" => "A927C19E-F74C-4FF6-8AAF-A4963DE6A32B",
      "User-Agent" => 'Tinder/8.0.0 (iPhone; iOS 10.3.3; Scale/2.00)',
      "app-session" => "a2fc7739760f2a86da9f1c8b98690920727029b4"
    }
  end
end
