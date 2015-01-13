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

if !ENV['TEAM_NAMES_SET'].nil? or !ENV['SEED_PLAYERS'].nil? or !ENV['SEED_GAMES'].nil?
  require 'features/support/transform_team_data'
  include TransformTeamData
end

def seed_admin
  admin = Admin.get
  unless admin.nil?
    User.delete_all
  end
  admin = User.new do |u|
    u.name = ENV['ALIASMADNESS_ADMIN']
    u.password = ENV['ALIASMADNESS_PASSWORD']
    u.password_confirmation = ENV['ALIASMADNESS_PASSWORD']
    u.email = ENV['ALIASMADNESS_ADMINEMAIL']
    u.role = 'admin'
  end
  admin.save!
  puts 'Seeded admin: '+admin.to_s
end

def seed_teams
  processed_teams= process_team_data team_data
  processed_teams.each do |t|
    list=Team.where('label=?', t[:label])
    list.update_all(name: t[:name])
  end
  Team.update_all(name_locked: :true)
  puts 'Set team names'
end

def build_new_player(player_file)
  player = User.new do |u|
    u.name= Faker::Name.name
    u.email= Faker::Internet.email(u.name)
    u.role= :player
  end
  player.save!
  player_file.write %Q(#{player.email} -- #{player.remember_for_email}\n)
  player
end

def choose_winners_for_brackets_games(bracket, down_to=1, label_losers=false)
  puts 'CHOOSING GAME WINNERS'
  games_by_label= hash_by_label(Game.find_all_by_bracket_id bracket.id)
  63.downto(down_to).each do |l|
    g= games_by_label[l.to_s]
    a= bracket.lookup_ancestors g
    g.winner= choose_winner a.to_a, label_losers
    g.save!
  end
end

def seed_players
  n_players= 22
  @players= []
  players_list= File.new('tmp/players_list', File::CREAT|File::TRUNC|File::RDWR, 0644)
  n_players.times do
    player= build_new_player players_list
    @players<< player
  end
  players_list.close
end


def seed_players_games
  @players.each do |player|
    bracket= player.bracket
    choose_winners_for_brackets_games bracket
  end
  Game.where('team_id is not null').update_all(locked: :true)
  User.where(role: :player).update_all(bracket_locked: :true)
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

OTHER=[1, 0]

def choose_winner(a, label_losers=false)
  r= rand(2)
  w= winner_from_ancestor a[r]
  eliminate_team a[OTHER[r]] if label_losers
  w
end

def eliminate_team(loser)
  # loser is either a Team or a Game-- get the Team from the Game
  loser= winner_from_ancestor(loser)
  loser.update_attributes!({eliminated: true})
  puts 'Eliminated '+loser.name
end

def winner_from_ancestor(a)
  if a.is_a? Game
    a.reload
    a= a.winner
  end
  a
end

def seed_result
  bracket= Admin.get.bracket
  choose_winners_for_brackets_games bracket, 25, true
end

seed_admin unless ENV['SEED_ADMIN'].nil?
seed_teams unless ENV['TEAM_NAMES_SET'].nil?
seed_players unless ENV['SEED_PLAYERS'].nil?
seed_players_games unless ENV['SEED_GAMES'].nil?
seed_result unless ENV['SEED_RESULT'].nil?
