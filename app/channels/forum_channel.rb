class ForumChannel < ApplicationCable::Channel
  def subscribed
    stream_from "forum_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def heckle(data)
    Heckle.create! content: data['message']
  end
end
