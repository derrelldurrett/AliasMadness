class ForumChannel < ApplicationCable::Channel
  def subscribed
    # How to identify the additional channel to which to subscribe?
    stream_from "forum_channel"
  end

  def unsubscribed
    # Any cleanup needed when channel is unsubscribed
  end

  def heckle(data)
    content, targets = process data
    Heckle.create! content: content, from_id: data['id'], targets: targets
  end

  private

  def process(data)
    targets = data['targets']
    content = data['message']
    unless targets.empty?
      targets = targets.map {|t| User.find(t.to_i)}
      content = tag_targets targets, content
      targets << User.find(data['id'])
    end
    [content, targets]
  end

  def tag_targets(targets, message)
    targets.each do |t|
      n = '@'+t.name
      message.gsub(n, "<b>#{n}</b>")
    end
    message
  end
end
