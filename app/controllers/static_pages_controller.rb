class StaticPagesController < ApplicationController
  include SessionsHelper
  def home
    if signed_in?
      redirect_to user_path(current_user.id)
    else
      render layout: false,
             file: %Q(#{ Rails.root }/public/404),
             formats: [:html],
             status: '404'
    end
  end

end
