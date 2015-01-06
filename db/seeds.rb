# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
def World(stuff)
  # Ha!
end

if !ENV['SEED_PLAYERS_AND_GAMES'].nil? or !ENV['TEAM_NAMES_SET'].nil? or !ENV['SEED_PLAYERS'].nil?
  require 'features/support/transform_team_data'
  include TransformTeamData
end

def seed_admin
  admin = Admin.get
  if admin.nil?
    admin = User.new do |u|
      u.name = ENV['ALIASMADNESS_ADMIN']
      u.password = ENV['ALIASMADNESS_PASSWORD']
      u.password_confirmation = ENV['ALIASMADNESS_PASSWORD']
      u.email = ENV['ALIASMADNESS_ADMINEMAIL']
      u.role = 'admin'
    end
    admin.save!
  end
end

def do_teams
  processed_teams= process_team_data team_data
  processed_teams.each do |t|
    list=Team.where('label=?', t[:label])
    list.update_all(name: t[:name])
  end
  Team.update_all(name_locked: :true)
end

def build_new_player(file_to_save)
  player = User.new do |u|
    u.name= Faker::Name.name
    pass= Faker::Internet.password(32, 32)
    u.password= pass
    u.password_confirmation= pass
    u.email= Faker::Internet.email(u.name)
    u.role= :player
  end
  player.save!
  file_to_save.write %Q(#{player.email} -- #{player.remember_for_email}\n)
  player
end

def choose_winners_for_brackets_games(bracket)
  puts 'CHOOSING GAME WINNERS'
  games_by_label= hash_by_label(Game.find_all_by_bracket_id bracket.id)
  63.downto(1).each do |l|
    g= games_by_label[l.to_s]
    a= bracket.lookup_ancestors g
    g.winner= choose_winner a.to_a
    g.save!
  end
end

def do_players_and_games
  n_players= 22
  players_list= File.new('tmp/players_list', File::CREAT|File::TRUNC|File::RDWR, 0644)
  n_players.times do
    player= build_new_player players_list
    bracket= player.bracket
    choose_winners_for_brackets_games bracket if !ENV['SEED_PLAYERS_AND_GAMES'].nil?
  end
  players_list.close
  if !ENV['SEED_PLAYERS_AND_GAMES'].nil?
    Game.where('team_id is not null').update_all(locked: :true)
    User.where(role: :player).update_all(bracket_locked: :true)
  end
end

def seed_teams_players_and_games
  do_teams
  do_players_and_games if !ENV['SEED_PLAYERS'].nil? or !ENV['SEED_PLAYERS_AND_GAMES'].nil?
end

def hash_by_label(labeled_entities)
  ret= Hash.new
  labeled_entities.each { |e| ret[e.label]= e }
  ret
end

def process_team_data(d)
  my_data= Array.new
  d.each do |t|
    my_data<< {label: t[:label], name: t[:new_name]}
  end
  my_data
end

def choose_winner(a)
  w= a[rand(2)]
  if w.is_a? Game
    w.reload
    w= w.winner
  end
  w
end

seed_admin
seed_teams_players_and_games if !ENV['TEAM_NAMES_SET'].nil? or !ENV['SEED_PLAYERS'].nil? or !ENV['SEED_PLAYERS_AND_GAMES'].nil?