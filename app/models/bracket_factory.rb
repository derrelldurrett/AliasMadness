require 'singleton'
require 'assets/rgl/directed_adjacency_graph'
require 'initialize_bracket/bracket_template'

class BracketFactory
  include Singleton
  attr_accessor :serialized_bracket

  def create_bracket
    # BracketTemplate should be passed the TemplateLoader from the
    # config: BracketTemplate.new(config.template_loader).copy
    @serialized_bracket ||= BracketTemplate.new(InitializeBracketFromTemplate.template_loader).copy
    bracket= Bracket.new
    instantiate_bracket bracket
    bracket.save!
    bracket
  end

  def instantiate_bracket(bracket)
    bracket.bracket_data= serialized_bracket.copy
    bracket.init_lookups bracket.bracket_data
  end
end
