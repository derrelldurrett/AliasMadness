class BracketsController < ApplicationController
  include SessionsHelper
  include UsersHelper
  before_filter :check_authorization, only: [:lock_brackets]
  respond_to :html, :json

  def update
    unless params[:game_data].nil?
      if game_data_processed? params[:game_data], params[:id]
        if current_user.admin? # only if admin...
          update_player_scores
          flash[:success]= 'Games saved!'
        else
          if all_games_chosen? params[:id]
            flash[:success]= 'Games saved!'
          else
            flash[:notice]= %Q(You have #{@games_remaining.length} games left to select.)
          end
        end
        respond_with true, {status: 204}
      else
        flash[:error]= 'Games NOT SAVED!'
        respond_with false, {status: 400}
      end
    else
      flash[:notice]= 'Nothing to do.'
      respond_with true, {status: 200}
    end
  end

  def all_games_chosen?(i)
    @games_remaining= Game.where(bracket_id: i, team_id: nil)
    @games_remaining.empty?
  end

  def show
    redirect_to user_path @current_user.id
  end

  def lock_brackets
    unless params[:lock_players_brackets].nil?
      lock_players_brackets
      flash[:success]= 'Players Brackets LOCKED!'
      respond_to do |format|
        format.json { render :json => current_user }
      end
    else
      flash[:error]= 'Players Brackets NOT LOCKED!'
      respond_to do |format|
        format.json { render :json => current_user }
      end
    end
  end

  private

  def game_data_processed?(data, bracket_id)
    ret= true
    Game.transaction do
      games_by_label= hash_by_label (Game.find_all_by_bracket_id bracket_id)
      data.each do |d|
        (game_label, winner_name, winner_label)= d
        game= games_by_label.fetch game_label.to_s
        # game.reload
        if winner_label.nil? or winner_label.empty? or winner_label=='Choose winner...' or winner_name.nil? or winner_name.empty?
          team=nil
          game.winner.update_attributes!({eliminated: false}) unless game.winner.nil?
        else
          team= Team.find_by_label winner_label
          if team.name != winner_name # sanity check
            ret= false
            flash.now[:error] =
                %Q(label/name mismatch! Expected winner #{winner_name}, got #{team.name})
            break
          end
          # if admin's bracket, mark losing team eliminated
          if current_user.admin?
            eliminate_loser(game_label, winner_label)
          end
        end
        game.update_attributes!({winner: team})
      end
    end
    ret
  end

  def eliminate_loser(game_label, winner_label)
    b= Admin.get.bracket
    ancestors= b.lookup_ancestors(b.lookup_game game_label)
    ancestors.each do |a|
      a_team= ancestor_team a
      if !a_team.nil? and a_team.label!=winner_label
        a_team.update_attributes!({eliminated: true})
        break
      end
    end
  end

  def lock_players_brackets
    # fixme so we make this one giant update of all games simultaneously
    User.where({role: :player}).each do |p|
      b= p.bracket
      b.games.update_all(locked: true)
      b.reload
    end
    User.where({role: :player}).update_all(bracket_locked: true)
  end

  def ancestor_team(ancestor)
    ancestor.is_a?(Team) ? ancestor : ancestor.winner
  end

  def hash_by_label(games)
    ret= Hash.new
    games.each { |g| ret[g.label]= g }
    ret
  end
end
