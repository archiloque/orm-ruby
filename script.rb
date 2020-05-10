require_relative 'model'
require_relative 'models'

Brick.truncate
Color.truncate

black = Color.new
black.name = 'Black'
black.insert

yellow = Color.new
yellow.name = 'Yellow'
yellow.insert

brick = Brick.new
brick.color = black
brick.name = 'Awesome brick'
brick.description = 'This brick is awesome'
brick.insert

puts black.bricks.length
puts black.bricks.first.name
exit

puts '# All colors'
Color.all.each do |color|
  puts color.id
  puts color.name
end

puts '# All Bricks'
Brick.all.each do |brick|
  puts brick.id
  puts brick.name
  puts brick.description
  puts brick.color_id
end

puts '# Black color'
Color.where('name = ?', 'Black').all.each do |color|
  puts color.id
  puts color.name
end

puts '# Color by name'
Color.order_by('name desc').all.each do |color|
  puts color.id
  puts color.name
end

puts '# First color by desc name'
color = Color.order_by('name desc').first
puts color.id
puts color.name
