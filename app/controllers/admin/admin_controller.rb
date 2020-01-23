class Admin
  class AdminController < ApplicationController
    require 'active_record/errors'
    include SessionsHelper
    include UsersHelper
    include BracketsHelper
    include AdminHelper
    before_action :check_authorization_admin
    respond_to :html

    # The ideal would be that only the admin ever sees this code, but that's gonna take some work
    #def bracket_update
    #  common_bracket_update
    #  update_player_scores
    #  respond_to do |format|
    #    format.html { render 'brackets/_bracket' }
    #  end
    #end

    def scenarios
      @user = Admin.get #   current_user
      @players = get_players_sorted_by_score
      @scenarios = build_scenarios
      respond_to do |format|
        format.html { render 'admin/scenarios' }
      end
    end
  end
end
