def init_bracket_data
  {
      10 => {
          '63': %w(126 127 127 127), # choose from 127 and 126
          '62': %w(124 124 124 124), # choose from 125 and 124
          '61': %w(122 122 122 122), # choose from 123 and 122
          '60': %w(120 120 120 120), # choose from 121 and 120
          '59': %w(118 118 118 118), # choose from 119 and 118
          '58': %w(116 116 116 116), # choose from 117 and 116
          '57': %w(114 114 114 114), # choose from 115 and 114
          '56': %w(112 112 112 112), # choose from 113 and 112
          '55': %w(110 110 110 110), # choose from 111 and 110
          '54': %w(108 108 108 108), # choose from 109 and 108
          '53': %w(106 106 106 106), # choose from 107 and 106
          '52': %w(104 104 104 104), # choose from 105 and 104
          '51': %w(102 102 102 102), # choose from 103 and 102
          '50': %w(100 100 100 100), # choose from 101 and 100
          '49': %w(98 98 98 98), # choose from 99 and 98
          '48': %w(96 96 96 96), # choose from 97 and 96
          '47': %w(94 94 94 94), # choose from 95 and 94
          '46': %w(92 92 92 92), # choose from 93 and 92
          '45': %w(90 90 90 90), # choose from 91 and 90
          '44': %w(88 88 88 88), # choose from 89 and 88
          '43': %w(86 86 86 86), # choose from 87 and 86
          '42': %w(84 84 84 84), # choose from 85 and 84
          '41': %w(82 82 82 82), # choose from 83 and 82
          '40': %w(80 80 80 80), # choose from 81 and 80
          '39': %w(78 78 78 78), # choose from 79 and 78
          '38': %w(76 76 76 76), # choose from 77 and 76
          '37': %w(74 74 74 74), # choose from 75 and 74
          '36': %w(72 72 72 72), # choose from 73 and 72
          '35': %w(70 70 70 70), # choose from 71 and 70
          '34': %w(68 69 69 69), # choose from 69 and 68
          '33': %w(66 66 66 66), # choose from 67 and 66
          '32': %w(64 64 64 64), # choose from 65 and 64
          '31': %w(124 127 127 127), # choose from 63 and 62
          '30': %w(122 122 122 122), # choose from 61 and 60
          '29': %w(118 118 118 118), # choose from 59 and 58
          '28': %w(112 112 112 112), # choose from 57 and 56
          '27': %w(110 110 110 110), # choose from 55 and 54
          '26': %w(106 106 106 106), # choose from 53 and 52
          '25': %w(102 102 102 102), # choose from 51 and 50
          '24': %w(96 96 96 96), # choose from 49 and 48
          '23': %w(94 94 94 94), # choose from 47 and 46
          '22': %w(90 90 90 90), # choose from 45 and 44
          '21': %w(86 86 86 86), # choose from 43 and 42
          '20': %w(80 80 80 80), # choose from 41 and 40
          '19': %w(78 78 78 78), # choose from 39 and 38
          '18': %w(74 74 74 74), # choose from 37 and 36
          '17': %w(70 69 69 69), # choose from 35 and 34
          '16': %w(64 64 64 64), # choose from 33 and 32
          '15': %w(122 127 127 127), # choose from 31 and 30
          '14': %w(112 112 112 112), # choose from 29 and 28
          '13': %w(110 110 110 110), # choose from 27 and 26
          '12': %w(96 96 96 96), # choose from 25 and 24
          '11': %w(94 94 94 94), # choose from 23 and 22
          '10': %w(80 80 80 80), # choose from 21 and 20
          '9': %w(78 78 78 78), # choose from 19 and 18
          '8': %w(70 69 69 69), # choose from 17 and 16
          '7': %w(112 127 127 127), # choose from 15 and 14
          '6': %w(110 96 96 96), # choose from 13 and 12
          '5': [nil, '94', '80', '80'], # choose from 11 and 10
          '4': [nil, '69', '69', '69'], # choose from 9 and 8
          '3': [nil, '96', '96', '127'], # choose from 7 and 6
          '2': [nil, '69', '69', '80'], # choose from 5 and 4
          '1': [nil, '96', '69', '127'] # choose from 3 and 2
          # Possible scenarios: (Not filtered by what's possible because of choices.)
          # game 5: 94 (Team 8 (2)) or 80 (Team 4 (1))
          # game 4: 78 (Team 6 (2)) or 69 (Team 49 (12))
          # game 3: 110 (Team 7 (2)), 96 (Team 2 (1)) or 127 (Team 61 (15))
          # game 2: 94 (Team 8 (2)), 80 (Team 4 (1)), 78 (Team 6 (2)), or 69 (Team 49 (12))
          # game 1: 110 (Team 7 (2)), 94 (Team 8 (2)), 80 (Team 4 (1)), 78 (Team 6 (2)), 69 (Team 49 (12)),
          #           96 (Team 2 (1)), or 127 (Team 61 (15))
      }
  }
end

# Return the admin, so we can pass it in to #build_scenarios
def init_brackets(bracket_key)
  admin_and_users = init_admin_and_players # admin at 0, users 1,2, and 3
  ActiveRecord::Base.transaction do
    init_bracket_data[bracket_key].each do |label, per_user_data|
      per_user_data.each_with_index do |users_team, i|
        next if users_team.nil?
        user = admin_and_users[i]
        game = user.bracket.lookup_game label
        game.winner= user.bracket.lookup_node users_team
        game.save!
        user.bracket.update_node game, game.label
      end
    end
    admin_and_users.each do |u|
      u.bracket.save!
    end
  end
  games_remaining = init_bracket_data[bracket_key].select { |_k, g| g[0].nil? }.length
  [admin_and_users[0], games_remaining]
end

def init_admin_and_players
  User.all.delete_all
  admin = create(:admin)
  ActiveRecord::Base.transaction do
    admin.bracket.games.each do |g|
      g.winner = nil
      g.save!
    end
    admin.bracket.save!
  end
  users = []
  3.times do
    users << create(:random_user)
  end
  [admin, users].flatten
end
