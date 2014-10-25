require 'singleton'
require 'assets/rgl/directed_adjacency_graph'
require 'initialize_bracket/bracket_template'

class BracketFactory
  include Singleton
  attr_accessor :serialized_bracket

  def create_bracket
    instantiate_bracket
  end

  def instantiate_bracket(bracket=nil)
    bracket||= Bracket.create # need the id!
    bracket.bracket_data||= serialized_bracket.copy
    puts 'initializing the bracket'
    bracket.init_lookups
    bracket.save!
    bracket
  end

  def serialized_bracket
    # BracketTemplate should be passed the TemplateLoader from the
    # config: BracketTemplate.new(config.template_loader).copy
    @serialized_bracket ||= BracketTemplate.new(InitializeBracketFromTemplate.template_loader).copy
  end
end
