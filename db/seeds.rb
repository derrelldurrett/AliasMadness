# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
def seed_admin
  users = User.find_all_by_name('admin')
  if users.nil? or users == []
    admin = User.new do |u|
      u.name = ENV['ALIASMADNESS_ADMIN']
      u.password = ENV['ALIASMADNESS_PASSWORD']
      u.password_confirmation = ENV['ALIASMADNESS_PASSWORD']
      u.email = ENV['ALIASMADNESS_ADMINEMAIL']
      u.role = 'admin'
    end
    admin.save!
    puts 'saving the admin at seed time'
  end
end

seed_admin
