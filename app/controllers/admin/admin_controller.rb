class Admin
  class AdminController < ApplicationController
    require 'active_record/errors'
    include SessionsHelper
    include UsersHelper
    include BracketsHelper
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
  end
end
