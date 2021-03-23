# frozen_string_literal: true
class TeamsController < ApplicationController
  include SessionsHelper
  include TeamsHelper
  before_action :check_authorization_admin

  # PUT /teams/1.json
  def update
    @team = Team.find(params[:id])
    @team.update! name: params[:team][:name]
    @bracket = Bracket.find(params[:bracket][:id])
    node = @bracket.update_node params[:team], params[:bracket][:node].to_s
    @bracket.save!
    respond_with node, {status: 200}
  end

  # PUT /lock_names
  def lock_names
    if params[:fix_team_names].nil?
      flash[:error]= 'Team names NOT LOCKED!'
      respond_with false, {status: 400}
    else
      lock_team_names
      flash[:success]= 'Team Names Locked!'
      respond_with true, {status: 204}
    end
  end

end
