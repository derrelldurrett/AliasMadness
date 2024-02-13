# frozen_string_literal: true
class BracketsController < ApplicationController
  include BracketsHelper
  include SessionsHelper
  include UsersHelper
  before_action :check_authorization_admin, only: [:lock_brackets]
  respond_to :html, :json

  def update
    id = params[:id]
    params = resource_params
    common_bracket_update id, params
    # I think the code here would be better in a method that only appears in the
    # AdminController namespace, but I can't exactly figure out how to do that....
    if current_user.admin?
      update_player_scores
      ScenarioFactory.new.build_scenarios current_user
    end
  end

  def show
    @bracket = Bracket.find(params[:id]).reload
  end

  def lock_brackets
    if params[:lock_players_brackets].nil?
      flash[:error]= 'Players Brackets NOT LOCKED!'.freeze
    else
      lock_players_brackets
      flash[:success]= 'Players Brackets LOCKED!'.freeze
    end
    respond_to { |format| format.json { render json: current_user } }
  end

  def scenarios
    @user = current_user
    @players = User.players.sorted_by_score
    @scenarios = Scenario.all
    respond_to do |format|
      format.html { render 'brackets/scenarios'.freeze }
    end
  end

  private

  def game_data_processed?(data, bracket_id)
    ret = true
    Bracket.transaction do
      Game.transaction do
        ret = update_games(bracket_id, data)
      end
    end
    ret
  end

  def update_games(bracket_id, data)
    ret = true
    games_by_label = hash_by_label Game.where(bracket_id: bracket_id)
    data.each do |d|
      ret = update_game(d, games_by_label)
      break unless ret
    end
    ret
  end

  def update_game(d, games_by_label)
    (game_label, winner_name, winner_label) = d
    game = games_by_label.fetch game_label.to_s
    team = get_team(game_label, winner_label, winner_name)
    return false if team.nil?
    game.update!({ winner: team })
    true
  end

  def get_team(game_label, winner_label, winner_name)
    if winner_label.nil? or winner_label == '' or winner_name.nil? or winner_name == ''
      team = nil
    else
      team = Team.find_by_label winner_label
      if team.name != winner_name
        flash.now[:error] =
            %Q(label/name mismatch! Expected winner #{winner_name}, got #{team.name})
        return
      end
      # if admin's bracket, mark losing team eliminated
      if current_user.admin?
        eliminate_loser(game_label, winner_label)
      end
    end
    team
  end

  def eliminate_loser(game_label, winner_label)
    b = Admin.get.bracket.reload
    ancestors = b.lookup_ancestors(b.lookup_game game_label)
    ancestors.each do |a|
      a_team = ancestor_team a
      unless a_team.nil? or a_team.label == winner_label
        a_team.update!(eliminated: true)
        break
      end
    end
  end

  def lock_players_brackets
    puts "locking players brackets"
    User.transaction do
      Bracket.transaction do
        Game.transaction do
          User.where(role: :player).each do |p|
            b= p.bracket
            b.games.update_all(locked: true)
            p.bracket_locked = true
            p.save!
          end
        end
      end
    end
  end

  def resource_params
    params.require(:bracket).permit!
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
