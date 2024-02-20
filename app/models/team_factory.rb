# frozen_string_literal: true

require 'singleton'
class TeamFactory
  include Singleton

  def find_or_create_team(label:, seed:, name:)
    @teams ||= load_teams_if_they_exist
    if @teams.has_key?(label)
      @teams[label]
    else
      @teams[label] = build_team(label: label, seed: seed, name: name)
    end
  end

  private def build_team(label:, seed:, name:)

    team = Team.new
    team.id = label.to_i
    team.label = label
    team.name_locked = false
    team.seed = seed
    team.eliminated = false
    team.name = generate_name(label, name)
    team
  end

  private def generate_name(label, name=nil)
    name.nil? ? "Team #{(label.to_i - 63)}" : validate_name(name)
  end

  private def load_teams_if_they_exist
    admin = Admin.get&.bracket
    if admin.present?
      admin.teams.each_with_object({}) { |t, h| h[t.label.to_s] = t }
    else
      {}
    end
  end


  private def set_name(name)
    @names[name] = true
    name
  end

  private def validate_name(name)
    @names ||= {}
    @names.has_key?(name) ? raise(NameAlreadyUsedError, "#{name} is already used for a team") : set_name(name)
  end
end
