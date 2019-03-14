require 'singleton'
require 'assets/rgl/directed_adjacency_graph'
require 'initialize_bracket/initialize_bracket_from_template'
require 'initialize_bracket/bracket_template'

class BracketFactory
  include Singleton

  def create_bracket
    bracket = instantiate_bracket Bracket.create
    bracket.save!
    bracket
  end

  def instantiate_bracket(bracket)
    bracket.bracket_data||= serialized_bracket.copy
    # bracket.init_lookups
    bracket
  end

  def serialized_bracket
    # BracketTemplate should be passed the TemplateLoader from the
    # config: BracketTemplate.new(config.template_loader).copy
    @serialized_bracket ||= BracketTemplate.new(InitializeBracketFromTemplate.template_loader).copy
  end
end
