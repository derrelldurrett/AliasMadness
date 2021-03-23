# frozen_string_literal: true
class Heckle < ApplicationRecord
  has_many :heckles_user
  has_many :targets, source: :user, through: :heckles_user
  after_create_commit :broadcast_and_trim

  private

  def broadcast_and_trim
    HeckleBroadcastJob.perform_now self
    # Keep only the 100 most-recent heckles
    Heckle.order(created_at: :desc).offset(100).delete_all
  end
end
