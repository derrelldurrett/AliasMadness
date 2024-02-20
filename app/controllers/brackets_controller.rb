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
  end

  def show
    @bracket = Bracket.find(params[:id]).reload
  end

  def lock_brackets
    if params[:lock_players_brackets].nil?
      flash[:error] = 'Players Brackets NOT LOCKED!'.freeze
    else
      lock_players_brackets
      flash[:success] = 'Players Brackets LOCKED!'.freeze
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
    ret = update_games(bracket_id, data)
    # I think the code here would be better in a method that only appears in the
    # AdminController namespace, but I can't exactly figure out how to do that....
    if current_user.admin?
      update_player_scores
      ScenarioFactory.new.build_scenarios current_user
    end
    ret
  end

  def team_data_processed?(data, bracket_id)
    ret = true
    Bracket.transaction do
      ret = update_team(bracket_id, data)
    end
    ret
  end

  def update_games(bracket_id, data)
    ret = true
    bracket = Bracket.find(bracket_id)
    Bracket.transaction do
      data.each do |d|
        ret = update_game(d, bracket)
        break unless ret
      end
      bracket.save!
    end
    ret
  end

  def update_game(d, bracket)
    (game_label, winner_name, winner_label) = d
    game = bracket.lookup_game game_label.to_s
    team = get_team(bracket, winner_label, winner_name, false)
    return false if team.nil?
    ret = true
    game.winner = team
    bracket.update_node(game, game_label.to_s)
    if current_user.admin?
      ret = eliminate_loser(bracket, d)
    end
    ret
  end

  def update_team(bracket_id, data)
    bracket = Bracket.find(bracket_id)
    name = data[:team][:name]
    team_label = data[:bracket][:node]
    team = get_team(bracket, team_label, name, true)
    team.name = name if name != team.name
    bracket.update_node team, team.label
    bracket.save!
  end

  def get_team(bracket, team_label, name, change_name)
    if team_label.nil? or team_label == ''
      team = nil
    else
      team = bracket.lookup_team team_label
        if not change_name and team.name != name
          flash.now[:error] =
            %Q(label/name mismatch! Expected winner #{name}, got #{team.name})
          return
        end
    end
    team
  end

  def eliminate_loser(bracket, data)
    (game_label, _name, winner_label) = data
    return if winner_label.nil?
    ancestors = bracket.lookup_ancestors(bracket.lookup_game game_label)
    ret = false
    ancestors.each do |a|
      a_team = ancestor_team a
      unless a_team.nil? or a_team.label == winner_label
        a_team.eliminated = true
        bracket.update_node(a_team, a_team.label)
        User.players.each do |p|
          p.bracket.update_node(a_team, a_team.label)
          ret = p.bracket.save
        end
        break
      end
    end
    ret
  end

  def lock_players_brackets
    puts "locking players brackets"
    User.transaction do
      Bracket.transaction do
        User.players.each do |p|
          b = p.bracket
          b.games.each { |g| g.locked = true }
          b.save!
          p.bracket_locked = true
          p.save!
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
    ret = Hash.new
    games.each { |g| ret[g.label] = g }
    ret
  end
end
