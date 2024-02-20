module TeamsHelper
  def team_names_locked?
    Admin.get.bracket.teams.all? { |t| t.name_locked? }
  end

  def lock_team_names
    admin_bracket = Admin.get.bracket
    admin_bracket.teams.each { |t| t.name_locked = true }
    admin_bracket.save!
  end
end
