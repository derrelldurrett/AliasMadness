# frozen_string_literal: true
require 'singleton'
require 'assets/rgl/directed_adjacency_graph'

class BracketFactory
  include Singleton

  def create_bracket
    bracket = instantiate_bracket Bracket.create
    bracket.save!
    bracket
  end

  def serialized_bracket
    # BracketTemplate should be passed the TemplateLoader from the
    # config: BracketTemplate.new(config.template_loader).copy
    @serialized_bracket ||= InitializeBracket::BracketTemplate.new(InitializeBracket::InitializeBracketFromTemplate.template_loader).copy
  end

  private

  def instantiate_bracket(bracket)
    bracket.bracket_data ||= serialized_bracket.copy
    instantiate_teams(bracket) if Admin.get&.bracket.present?
    bracket
  end

  def instantiate_teams(bracket)
    @stored_teams ||= Admin.get.bracket.teams
    @stored_teams.each { |t| bracket.lookup_by_label[t.label] = t }
  end
end
