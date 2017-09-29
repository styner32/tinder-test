require './matcher'

m = Matcher.new
m.authenticate

ids = {}
traveling = true

1.times do
  items = m.fetch
  if items == nil || items.size == 0
    puts "done!!"
    break
  end

  puts "fetched: #{items.count}"

  items.each do |item|
    user = item["user"]
    next unless user

    puts user
    id = user["_id"]
    content_hash = item["content_hash"]
    distance = item["distance_mi"]
    female = user["gender"] == 1

    unless female
      puts "I am not ready for this."
      next
    end

    if !traveling && (!distance || distance > 12)
      puts "too far from here: #{user['distance_mi']}"
      next
    end

    if ids[id]
      puts "duplicated"
      next
    end

    ids[id] = true

    puts "birth_date: #{user["birth_date"]} bio: #{user['bio']}"
    puts user["photos"].map { |p| p["url"] }
    puts m.like(id, content_hash, traveling)
    sleep(1 + rand(10) / 10.0)
  end

  puts "Total likes: #{ids.count}"
  # sleep(10 + rand(10))
end
