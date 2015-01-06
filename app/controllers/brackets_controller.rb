class BracketsController < ApplicationController
  include SessionsHelper
  include UsersHelper
  before_filter :check_authorization, only: [:lock_brackets]
  respond_to :html, :json

  def update
    unless params[:game_data].nil?
      if game_data_processed? params[:game_data], params[:id]
        update_player_scores if current_user.admin? # only if admin...
        flash[:success]= 'Games saved!'
        respond_with true, {status: 204}
      else
        flash[:error]= 'Games NOT SAVED!'
        respond_with false, {status: 400}
      end
    else
      flash[:error]= 'Request FAILED!'
      respond_with false, {status: 400}
    end
  end

  def show
    @bracket = Bracket.find(params[:id])
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
    games_by_label= hash_by_label (Game.find_all_by_bracket_id bracket_id)
    data.each do |d|
      (game_label,winner_name,winner_label)= d
      game= games_by_label.fetch game_label.to_s
      if winner_label.nil? or winner_label=='' or winner_name.nil? or winner_name==''
        team=nil
      else
        team= Team.find_by_label winner_label
        if team.name != winner_name
          ret= false
          flash.now[:error] =
              %Q(label/name mismatch! Expected winner #{winner_name}, got #{team.name})
          break
        end
        # if admin's bracket, mark losing team eliminated
        if current_user.admin?
          b= Admin.get.bracket
          ancestors= b.lookup_ancestors(b.lookup_game game_label)
          ancestors.each do |a|
            a_team= ancestor_team a
            unless a_team.label==winner_label
              a_team.update_attributes!({eliminated: true})
              break
            end
          end
        end
      end
      game.update_attributes!({winner: team})
    end
    ret
  end

  def lock_players_brackets
    User.where({role: :player}).update_all(bracket_locked: true)
  end

  private

  def ancestor_team(ancestor)
    ancestor.is_a?(Team) ? ancestor : ancestor.winner
  end

  def hash_by_label(games)
    ret= Hash.new
    games.each { |g| ret[g.label]= g }
    ret
  end
end
