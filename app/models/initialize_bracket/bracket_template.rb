require 'rgl/base'
require 'rgl/adjacency'
require 'assets/template_loader'

class BracketTemplate
  @@saved_template_loader
  @@common_template_as_nodes=nil

  attr_reader :template_as_nodes, :label_lookup
  attr :entry_node #, :iterator

  def initialize(template_loader = TemplateLoader.new)
    @@saved_template_loader ||= init_saved_template_loader(template_loader)
    @template_as_nodes = @@saved_template_loader.build_graph
    @label_lookup = @@saved_template_loader.label_lookup
    iterator
  end

  def init_saved_template_loader(template_loader)
    @template_as_array =
      @@template_as_array ||=
          template_loader.load_template(InitializeBracketFromTemplate.bracket_specification_file)
    template_loader
  end

  def depth_first_search(&b)
    @template_as_nodes.depth_first_search(&b)
  end

  def multiplicity
    @template_as_nodes.multiplicity
  end

  def out_degree(v)
    @template_as_nodes.out_degree(v)
  end

  def copy
    BracketTemplate.new(@@saved_template_loader)
  end

  def entry_node
    @template_as_nodes.entry_node
  end

  def iterator
    @template_as_nodes.iterator
  end

  def vertices
    @template_as_nodes.vertices
  end

  def self.load(serialization)
    @@template_as_nodes=
        RGL::DirectedAdjacencyGraph.load serialization
  end

  def dump
    @template_as_nodes.edges.dump
  end
end
