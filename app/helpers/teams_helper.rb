module TeamsHelper
  def team_names_locked?
    Team.any? { |t| t.name_locked? }
  end

  def lock_team_names
    Team.update_all name_locked: :true
  end
end
