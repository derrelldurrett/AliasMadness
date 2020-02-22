class Heckle < ApplicationRecord
  # Need an additional after_create_commit action that trims the list of Heckles, so
  # it doesn't grow uncontrollably
  after_create_commit { HeckleBroadcastJob.perform_now self }
end
