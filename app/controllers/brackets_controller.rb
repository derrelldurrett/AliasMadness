class BracketsController < ApplicationController

  respond_to :html, :json
  def update
    @bracket ||= Bracket.find(params[:id])
    # Maybe don't need to return @team ?
    team = @bracket.update_team_name params[:team][:name], params[:bracket][:node].to_s
    respond_with team, {status: 200}
  end

  def show
    @bracket ||= Bracket.find(params[:id])
  end
end
