# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ name: 'Chicago' }, { name: 'Copenhagen' }])
#   Mayor.create(name: 'Emanuel', city: cities.first)
def World(_stuff)
  # Ha!
end

if not ENV['TEAM_NAMES_SET'].nil? or not ENV['SEED_PLAYERS'].nil? or not ENV['SEED_GAMES'].nil?
  require_relative '../features/support/transform_team_data'
  include TransformTeamData
end

def delete_db_contents
  Bracket.destroy_all
  User.destroy_all
end

def seed_admin
  admin = User.new do |u|
    u.name = ENV['ALIASMADNESS_ADMIN']
    u.password = ENV['ALIASMADNESS_PASSWORD']
    u.password_confirmation = ENV['ALIASMADNESS_PASSWORD']
    u.email = ENV['ALIASMADNESS_ADMINEMAIL']
    u.role = :admin
  end
  admin.save!
  admin = Admin.get
  puts "Seeded admin: #{admin} -- #{admin.email}"
end

def seed_teams
  @processed_teams = process_team_data team_data
  admin = Admin.get
  @admins_bracket = admin.bracket
  @processed_teams.each do |t|
    bracket_team = @admins_bracket.lookup_node t[:label]
    bracket_team.name = t[:name]
    bracket_team.name_locked = true
  end
  @admins_bracket.save!
  puts 'Set team names'
end

def build_new_player(player_file)
  player = User.new do |u|
    u.name = Faker::Name.name
    u.email = Faker::Internet.email(name: u.name)
    u.role = :player
  end
  player.save!
  init_players_bracket_from_admin(player)
  player_file.write %Q(#{player.email} -- #{player.remember_for_email}\n)

  player
end

def init_players_bracket_from_admin(player)
  @processed_teams.each do |t|
    team = @admins_bracket.lookup_node t[:label]
    player.bracket.lookup_by_label[team.label] = team
  end
  player.save!
end

def choose_winners_in_bracket(bracket, down_to = 1, label_losers = false)
  return if down_to > 63

  puts 'CHOOSING GAME WINNERS'
  63.downto(down_to).each do |l|
    g = bracket.lookup_game l.to_s
    a = bracket.lookup_ancestors g
    g.winner = choose_winner a.to_a, label_losers
    g.locked = true
    bracket.lookup_by_label[l.to_s] = g
  end
  bracket.save!
end

def seed_players
  n_players = 22
  @players = []
  players_list = File.new('tmp/players_list', File::CREAT | File::TRUNC | File::RDWR, 0644)
  n_players.times do
    player = build_new_player players_list
    @players << player
  end
  players_list.close
end

def seed_players_games
  @players.each do |player|
    bracket = player.bracket
    choose_winners_in_bracket bracket
  end
  User.where(role: :player).update_all(bracket_locked: true) unless ENV['LOCK_BRACKETS'].nil?
  puts 'seeded games'
end

def process_team_data(d)
  my_data = []
  d.each do |t|
    my_data << {label: t[:label], name: t[:new_name]}
  end
  my_data
end

OTHER = [1, 0]

def choose_winner(a, label_losers = false)
  r = rand(2)
  w = a[r].is_a?(Game) ? a[r].winner : a[r]
  eliminate_team a[OTHER[r]] if label_losers
  w
end

def eliminate_team(ancestor)
  # loser is either a Team or a Game-- get the Team from the Game
  previous_winner = ancestor.is_a?(Game) ? ancestor.winner : ancestor
  previous_winner.eliminated = true
  puts "Eliminated #{previous_winner.name}"
end

def seed_result
  bracket = Admin.get.bracket
  choose_winners_in_bracket bracket, default_game_label, true
  bracket.save
  @players.each { |p| p.score bracket }
end

# because this gets fed into a #downto() call, it's going to only work to calculate
# values between 63 and 1. If you want no games, return a number greater than 63.
# Thus, the default is to seed no rounds.
def default_game_label
  rounds_to_seed = ENV.include?('ROUNDS_TO_SEED') ? ENV['ROUNDS_TO_SEED'] : 0
  2**(6 - rounds_to_seed.to_i)
end

delete_db_contents
seed_admin unless ENV['SEED_ADMIN'].nil?
seed_teams unless ENV['TEAM_NAMES_SET'].nil?
seed_players unless ENV['SEED_PLAYERS'].nil?
seed_players_games unless ENV['SEED_GAMES'].nil?
seed_result unless ENV['SEED_RESULT'].nil?
