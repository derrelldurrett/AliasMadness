# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
admin = User.new(
    name: 'admin',
    password: 'foobaer',
    password_confirmation: 'foobaer',
    email: 'foo@bar.com',
    role: 'admin')
admin.save!
puts 'Admin Bracket: '
puts admin.bracket.id
puts 'Admin Bracket\'s Game 32: '
puts admin.bracket.lookup_node('32').id
