class BracketsController < ApplicationController

  respond_to :html, :json
  def update
    if !params[:team].nil?
      team= Team.find_by_id(params[:team][:id])
      team.update_attributes!({name: params[:team][:name]})
      @bracket = Bracket.find(params[:id])
      team = @bracket.update_node team, params[:bracket][:node].to_s
      respond_with team, {status: 200}
      @bracket.save!
    elsif !params[:game_data].nil?
      if process_game_data params[:game_data],params[:id]
        respond_with true, {status: 204}
      else
        respond_with false, {status: 400}
      end
    end
  end

  def show
    @bracket = Bracket.find(params[:id])
  end

  private

  def process_game_data(data, bracket_id)
    ret= true
    games_by_label= hash_by_label (Game.find_all_by_bracket_id bracket_id)
    data.each do |d|
      (game_label,winner_name,winner_label)= d
      game= games_by_label.fetch game_label.to_s
      if winner_label.nil? or winner_label=='' or winner_name.nil? or winner_name==''
        team=nil
      else
        team= Team.find_by_label winner_label
        puts (team.nil? or team.name.nil?) ? 'team broken'+team.to_s : 'team: '+team.to_s+', winner: '+winner_name
        if team.name != winner_name
          ret= false
          break
        end
      end
      game.update_attributes!({winner: team})
    end
    ret
  end

  def hash_by_label(games)
    ret= Hash.new
    games.each { |g| ret[g.label]= g }
    ret
  end
end
