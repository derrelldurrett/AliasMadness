require 'assets/rgl/directed_adjacency_graph'
require 'initialize_bracket/bracket_template'
class Bracket < ActiveRecord::Base
  include HashHelper
  serialize :bracket_data, BracketTemplate
  serialize :lookup_by_label, Hash
  attr_accessible :bracket_data
  belongs_to :user#, inverse_of: :brackets
  has_many :games, inverse_of: :brackets

  HashHelper.hash_vars= %i(id user)
  #def initialize(attributes={})
  #  super
  #  #self.hash_vars= %i(id user)
  #end

  def initialization_data
    bracket_data.template_as_nodes.edges
  end

  def lookup_game(l)
    init_lookups bracket_data if lookup_by_label.nil?
    begin
      @lookup_by_label.fetch(Game).fetch l
    rescue KeyError
      nil
    end
  end

  def lookup_team(l)
    init_lookups bracket_data  if lookup_by_label.nil?
    begin
      @lookup_by_label.fetch(Team).fetch l
    rescue KeyError
      nil
    end
  end

  def lookup_node(n)
    init_lookups bracket_data
    lookup_game(n) || lookup_team(n)
  end

  def lookup_ancestors(g)
    init_lookups bracket_data
    begin
      @bracket_ancestors.fetch g
    rescue KeyError
      nil
    end
  end

  def eql?(o)
    unless self.class.eql?(o.class)
      return false
    end
    self.initialization_data.zip(o.initialization_data).
    all? { |a| a[0].eql? a[1] }
  end

  def init_lookups(graph_container)
    init_lookup_by_label(graph_container)
    init_ancestors(graph_container)
    init_relationships
  end

  private

  attr :lookup_by_label, :bracket_ancestors


  def init_ancestors(graph_container)
    if @bracket_ancestors.nil?
      @bracket_ancestors = Hash.new { |h, k| h[k]= Set.new }
      graph_container.template_as_nodes.edges.each do |e|
        @bracket_ancestors[e.source] << e.target
      end
    end
  end

  def init_lookup_by_label(graph_container)
    if @lookup_by_label.nil?
      @lookup_by_label= Hash.new { |h, k| h[k] = Hash.new }
      graph_container.template_as_nodes.vertices.each do |v|
        @lookup_by_label[v.class][v.label] = v
      end
    end
  end

  def init_relationships
    bracket_data.template_as_nodes.vertices.each do |v|
      if(v.class.eql?(Game) and v.bracket_id.nil?)
        v.bracket_id= self.id
        v.save!
      end
    end
  end

end


