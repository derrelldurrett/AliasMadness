class HeckleBroadcastJob < ApplicationJob
  queue_as :default

  def perform(heckle)
    # Presumably, when I'm ready to add private channels, I can
    # get the channel from the heckle object being passed in? Or at least compute it?
    ActionCable.server.broadcast "forum_channel", {heckle: render_heckle(heckle)}
  end

  private

  def render_heckle(heckle)
    u = User.find(heckle.from_id)
    ApplicationController.renderer.render partial: 'heckles/heckle',
                                          locals: { heckle: heckle, this_user: u }
  end
end
