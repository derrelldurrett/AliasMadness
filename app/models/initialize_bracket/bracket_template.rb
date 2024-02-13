# frozen_string_literal: true
require 'rgl/base'
require 'rgl/adjacency'

module InitializeBracket
  class BracketTemplate < RGL::DirectedAdjacencyGraph

    attr_reader :template_as_nodes
    attr :entry_node

    def self.saved_template_loader
      if @saved_template_loader.nil?
        InitializeBracketFromTemplate.template_loader.load_template(InitializeBracketFromTemplate.bracket_specification_file)
        @saved_template_loader = InitializeBracketFromTemplate.template_loader
      end
      @saved_template_loader
    end

    def self.saved_template_loader=(template_loader)
      @saved_template_loader = template_loader
    end

    def initialize(template_loader = TemplateLoader.instance)
      super(Set) # constructor's argument is edge_list's class
      init_saved_template_loader(template_loader)
      @template_as_nodes = self.class.saved_template_loader.build_graph self
      iterator
    end

    def init_saved_template_loader(template_loader)
      template_loader.load_template(InitializeBracketFromTemplate.bracket_specification_file)
      self.class.saved_template_loader = template_loader
    end

    def copy
      BracketTemplate.new(self.class.saved_template_loader)
    end

    # Not sure this is a good idea. Just delegates to TemplateLoader, which
    # means that this looks up, for example, the Game that is in the original
    # template, rather than those attached to the Bracket
    def label_lookup
      self.class.saved_template_loader.label_lookup
    end

    def self.load(serialization)
      @template_as_nodes = super.load serialization
    end

    def dump
      @template_as_nodes.edges.dump
    end
  end
end