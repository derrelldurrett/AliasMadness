class TeamsController < ApplicationController
  include SessionsHelper
  include TeamsHelper
  before_filter :check_authorization
  respond_to :json

  # PUT /teams/1.json
  def update
    @team = Team.find(params[:id])
    @team.update_attributes!({name: params[:team][:name]})
    @bracket = Bracket.find(params[:bracket][:id])
    node = @bracket.update_node params[:team], params[:bracket][:node].to_s
    @bracket.save!
    respond_with node, {status: 200}
  end

  # PUT /lock_names
  def lock_names
    unless params[:fix_team_names].nil?
      lock_team_names
      flash[:success]= 'Team Names Locked!'
      respond_with true, {status: 204}
    else
      flash[:error]= 'Team names NOT LOCKED!'
      respond_with false, {status: 400}
    end
  end

end
