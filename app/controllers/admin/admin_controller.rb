class Admin
  class AdminController < ApplicationController
    require 'active_record/errors'
    include SessionsHelper
    include UsersHelper
    include AdminHelper
    before_action :check_authorization_admin
    respond_to :html

    def scenarios
      @user = Admin.get #   current_user
      @players = get_players_sorted_by_score
      @scenarios = build_scenarios
      respond_to do |format|
        format.html {render 'admin/scenarios'}
      end
    end
  end
end
