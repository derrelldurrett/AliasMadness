=begin
label: 127, seed: 15, id: 63, name: Team 61
label: 126, seed: 2, id: 64, name: Team 5
label: 125, seed: 10, id: 61, name: Team 37
label: 124, seed: 7, id: 62, name: Team 26
label: 123, seed: 14, id: 59, name: Team 57
label: 122, seed: 3, id: 60, name: Team 12
label: 121, seed: 11, id: 57, name: Team 42
label: 120, seed: 6, id: 58, name: Team 24
label: 119, seed: 13, id: 55, name: Team 52
label: 118, seed: 4, id: 56, name: Team 13
label: 117, seed: 12, id: 53, name: Team 66
label: 116, seed: 5, id: 54, name: Team 17
label: 115, seed: 9, id: 51, name: Team 33
label: 114, seed: 8, id: 52, name: Team 29
label: 113, seed: 16, id: 49, name: Team 65
label: 112, seed: 1, id: 50, name: Team 3
label: 111, seed: 15, id: 47, name: Team 59
label: 110, seed: 2, id: 48, name: Team 7
label: 109, seed: 10, id: 45, name: Team 38
label: 108, seed: 7, id: 46, name: Team 27
label: 107, seed: 14, id: 43, name: Team 58
label: 106, seed: 3, id: 44, name: Team 11
label: 105, seed: 11, id: 41, name: Team 43
label: 104, seed: 6, id: 42, name: Team 22
label: 103, seed: 13, id: 39, name: Team 55
label: 102, seed: 4, id: 40, name: Team 14
label: 101, seed: 12, id: 37, name: Team 46
label: 100, seed: 5, id: 38, name: Team 18
label: 99, seed: 9, id: 35, name: Team 35
label: 98, seed: 8, id: 36, name: Team 32
label: 97, seed: 16, id: 33, name: Team 64
label: 96, seed: 1, id: 34, name: Team 2
label: 95, seed: 15, id: 31, name: Team 62
label: 94, seed: 2, id: 32, name: Team 8
label: 93, seed: 10, id: 29, name: Team 39
label: 92, seed: 7, id: 30, name: Team 28
label: 91, seed: 14, id: 27, name: Team 68
label: 90, seed: 3, id: 28, name: Team 10
label: 89, seed: 11, id: 25, name: Team 41
label: 88, seed: 6, id: 26, name: Team 23
label: 87, seed: 13, id: 23, name: Team 53
label: 86, seed: 4, id: 24, name: Team 16
label: 85, seed: 12, id: 21, name: Team 51
label: 84, seed: 5, id: 22, name: Team 20
label: 83, seed: 9, id: 19, name: Team 36
label: 82, seed: 8, id: 20, name: Team 31
label: 81, seed: 16, id: 17, name: Team 63
label: 80, seed: 1, id: 18, name: Team 4
label: 79, seed: 15, id: 15, name: Team 60
label: 78, seed: 2, id: 16, name: Team 6
label: 77, seed: 10, id: 13, name: Team 40
label: 76, seed: 7, id: 14, name: Team 25
label: 75, seed: 14, id: 11, name: Team 56
label: 74, seed: 3, id: 12, name: Team 9
label: 73, seed: 11, id: 9, name: Team 44
label: 72, seed: 6, id: 10, name: Team 21
label: 71, seed: 13, id: 7, name: Team 54
label: 70, seed: 4, id: 8, name: Team 15
label: 69, seed: 12, id: 5, name: Team 49
label: 68, seed: 5, id: 6, name: Team 19
label: 67, seed: 9, id: 3, name: Team 34
label: 66, seed: 8, id: 4, name: Team 30
label: 65, seed: 16, id: 1, name: Team 67
label: 64, seed: 1, id: 2, name: Team 1

1.upto(12).each {|i| puts %Q/#{i} -- teams: #{JSON.parse(Scenario.find(i).scenario_teams).join(', ')}\n\t res: #{JSON.parse(Scenario.find(i).result).join(', ')}/ }

1 -- teams: Round 4: Team 6 (2), Round 5: Team 61 (15), Team 4 (1), Round 6: Team 61 (15)
	 res: some_player_3 (2572), some_player_1 (1164), some_player_2 (1132)
2 -- teams: Round 4: Team 6 (2), Round 5: Team 61 (15), Team 4 (1), Round 6: Team 4 (1)
	 res: some_player_3 (1612), some_player_1 (1164), some_player_2 (1132)
3 -- teams: Round 4: Team 6 (2), Round 5: Team 61 (15), Team 6 (2)
	 res: some_player_3 (1612), some_player_1 (1228), some_player_2 (1132)
4 -- teams: Round 4: Team 6 (2), Round 5: Team 2 (1), Team 4 (1), Round 6: Team 2 (1)
	 res: some_player_1 (1260), some_player_2 (1164), some_player_3 (1132)
5 -- teams: Round 4: Team 6 (2), Round 5: Team 2 (1), Team 4 (1), Round 6: Team 4 (1)
	 res: some_player_1 (1196), some_player_2 (1164), some_player_3 (1132)
6 -- teams: Round 4: Team 6 (2), Round 5: Team 2 (1), Team 6 (2)
	 res: some_player_1 (1260), some_player_2 (1164), some_player_3 (1132)
7 -- teams: Round 4: Team 49 (12), Round 5: Team 61 (15), Team 4 (1), Round 6: Team 61 (15)
	 res: some_player_3 (2764), some_player_2 (1324), some_player_1 (1132)
8 -- teams: Round 4: Team 49 (12), Round 5: Team 61 (15), Team 4 (1), Round 6: Team 4 (1)
	 res: some_player_3 (1804), some_player_2 (1324), some_player_1 (1132)
9 -- teams: Round 4: Team 49 (12), Round 5: Team 61 (15), Team 49 (12)
	 res: some_player_3 (2188), some_player_2 (1708), some_player_1 (1132)
10 -- teams: Round 4: Team 49 (12), Round 5: Team 2 (1), Team 4 (1), Round 6: Team 2 (1)
	 res: some_player_2 (1356), some_player_3 (1324), some_player_1 (1228)
11 -- teams: Round 4: Team 49 (12), Round 5: Team 2 (1), Team 4 (1), Round 6: Team 4 (1)
	 res: some_player_2 (1356), some_player_3 (1324), some_player_1 (1164)
12 -- teams: Round 4: Team 49 (12), Round 5: Team 2 (1), Team 49 (12)
	 res: some_player_2 (1740), some_player_3 (1708), some_player_1 (1164)
=end
def init_bracket_data
  {
      '63': %w(127 127 127 127), # choose from 127 and 126
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
      '34': %w(69 69 69 69), # choose from 69 and 68
      '33': %w(66 66 66 66), # choose from 67 and 66
      '32': %w(64 64 64 64), # choose from 65 and 64
      '31': %w(127 127 127 127), # choose from 63 and 62
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
      '17': %w(69 69 69 69), # choose from 35 and 34
      '16': %w(64 64 64 64), # choose from 33 and 32
      '15': %w(127 127 127 127), # choose from 31 and 30
      '14': %w(112 112 112 112), # choose from 29 and 28
      '13': %w(110 110 110 110), # choose from 27 and 26
      '12': %w(96 96 96 96), # choose from 25 and 24
      '11': %w(94 94 94 94), # choose from 23 and 22
      '10': %w(80 80 80 80), # choose from 21 and 20
      '9': %w(78 78 78 78), # choose from 19 and 18
      '8': %w(69 69 69 69), # choose from 17 and 16
      '7': [nil, '127', '127', '127'], # choose from 15 and 14
      '6': [nil, '96', '96', '96'], # choose from 13 and 12
      '5': [nil, '80', '80', '80'], # choose from 11 and 10
      '4': [nil, '69', '69', '69'], # choose from 9 and 8
      '3': [nil, '96', '96', '127'], # choose from 7 and 6
      '2': [nil, '69', '69', '69'], # choose from 5 and 4
      '1': [nil, '96', '69', '127'] # choose from 3 and 2
      # Possible scenarios:
      # game 7: 64 (Team 3 (1)) or 127 (Team 61 (15))
      # game 6: 110 (Team 7 (2)) or 96 (Team 2 (1))
      # game 5: 94 (Team 8 (2)) or 80 (Team 4 (1))
      # game 4: 78 (Team 6 (2)) or 69 (Team 49 (12))
      # game 3: 110 (Team 7 (2)), 96 (Team 2 (1)) or 127 (Team 61 (15))
      # game 2: 94 (Team 8 (2)), 80 (Team 4 (1)), 78 (Team 6 (2)), or 69 (Team 49 (12))
      # game 1: 110 (Team 7 (2)), 94 (Team 8 (2)), 80 (Team 4 (1)), 78 (Team 6 (2)), 69 (Team 49 (12)),
      #           96 (Team 2 (1)), or 127 (Team 61 (15))
  }
end

def init_brackets
  admin_and_users = init_admin_and_players # admin at 0, users 1,2, and 3
  ActiveRecord::Base.transaction do
    init_bracket_data.each do |label, per_user_data|
      per_user_data.each_with_index do |users_team, i|
        next if users_team.nil?
        user = admin_and_users[i]
        game = user.bracket.lookup_game label
        game.winner= user.bracket.lookup_node users_team
        game.save!
      end
    end
  end
  init_bracket_data.select { |_k, g| g[0].nil? }.length
end

def init_admin_and_players
  admin = create :admin
  users = []
  3.times do
    users << create(:random_user)
  end
  [admin, users].flatten
end
