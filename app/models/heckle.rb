class Heckle < ApplicationRecord
  # Need an additional after_create_commit action that trims the list of Heckles, so
  # it doesn't grow uncontrollably
  after_create_commit :broadcast_and_trim

  private

  def broadcast_and_trim
    HeckleBroadcastJob.perform_now self
    # Keep only the 100 most-recent heckles
    Heckle.order(created_at: :desc).offset(100).delete_all
  end
end
