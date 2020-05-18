class PrivateChannel < ApplicationCable::Channel
  def subscribed
    u = current_user
    logger.info("#{caller_locations(0, 1)}\n\tUser #{u} on #{String(broadcasting_for(u))}")
    stream_for u
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end
end
