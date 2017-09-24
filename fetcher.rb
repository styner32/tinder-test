require 'http'
require 'json'
require 'yaml'
require 'zlib'
require 'stringio'
require './headers'

def fetch(token)
  headers = get_headers(token)
  puts headers
  options = HTTP::Options.new(headers: get_headers(token))
  res = HTTP.get("https://api.gotinder.com/v2/recs/core?fast_match=1&locale=en-SG", options)

  gz = Zlib::GzipReader.new(StringIO.new(res.body.to_s))

  result = JSON.parse(gz.read)
  puts result
  return result["data"]["results"]
end

