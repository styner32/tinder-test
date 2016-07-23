require './config'
require './gettoken'
require './fetcher'
require './like'

token = gettoken["token"]

ids = {}

1000.times do
  items = fetch(token)

  if items == nil || items.size == 0
    puts "done!!"
    break
  end

  items.each do |item|
    user = item["user"]
    unless user
      p user
      next
    end

    id = user["_id"]
    content_hash = user["content_hash"]
    female = user["gender"] == 1

    unless female
      puts "Wrong gender!!!!"
      next
    end

    puts "birth_date: #{user["birth_date"]} from: #{user['distance_mi']}, bio: #{user['bio']}"
    if ids[id]
      puts "duplicated"
    else
      puts user["photos"].map { |p| p["url"] }
      p like(token, id, content_hash, true)
      ids[id] = true
      # sleep(1 + rand(10) / 10.0)
    end
  end

  puts "Total likes: #{ids.count}"
  sleep(10 + rand(10))
end
