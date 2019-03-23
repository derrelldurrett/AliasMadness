class Admin
  class AdminController < ApplicationController
    require 'active_record/errors'
    include SessionsHelper
    include UsersHelper
    include AdminHelper
    respond_to :html

    def scenarios
      respond_to do |format|
        @user = current_user
        @players = get_players_sorted_by_score
        @scenarios = build_scenarios
        format.html {render 'admin/scenarios'}
      end
    end
  end
end
