# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)

evedata ||= Faraday.new(:url => "http://evedata.herokuapp.com") do |conn|
	conn.request :json
	conn.response :json, :content_type => /\bjson$/
	conn.adapter Faraday.default_adapter
end

puts "Caching: blueprint groups: /categories/9/groups?limit=200"
all_groups = Rails.cache.fetch("category.9.groups") { evedata.get("/categories/9/groups?limit=200").body }

puts "Caching: all blueprint group members: /blueprints?group_id=XXXX&limit=200"
puts "WARNING: This will take a while :{\n"
all_groups.each do |group|
  blueprints = Rails.cache.fetch("group.#{group['id']}.members") { evedata.get("/blueprints?group_id=#{group['id']}&limit=200").body }
=begin
  blueprints.each do |item|
    puts "Caching: details for #{item['name']}"
    Rails.cache.fetch("blueprint.#{item['id']}.details") { evedata.get("/blueprints/#{item['id']}").body.first }
  end
=end
end

puts "Whew... all done!!"
