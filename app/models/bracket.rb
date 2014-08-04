require 'assets/rgl/directed_adjacency_graph'
require 'initialize_bracket/bracket_template'
require 'helpers/hash_helper'
class Bracket < ActiveRecord::Base
  include HashHelper
  serialize :bracket_data, BracketTemplate
  serialize :lookup_by_label, Hash
  attr_accessible :bracket_data
  belongs_to :user#, inverse_of: :brackets
  has_many :games, inverse_of: :brackets

  HashHelper.hash_vars= %i(id user)

  def teams
    @lookup_by_label.fetch(Team)
  end

  def teams_attributes=(name)
    puts "Got attributes: #{name}"
  end

  def initialization_data
    bracket_data.template_as_nodes.edges
  end

  def lookup_game(l)
    begin
      init_lookups bracket_data if lookup_by_label.nil?
      @lookup_by_label.fetch(Game).fetch l
    rescue KeyError
      nil
    rescue => unknown
      throw BadProgrammerError(unknown)
    end
  end

  def lookup_team(l)
    begin
      init_lookups bracket_data  if lookup_by_label.nil?
      @lookup_by_label.fetch(Team).fetch l
    rescue KeyError
      nil
    rescue => unknown
      raise BadProgrammerError(unknown)
    end
  end

  def lookup_node(n)
    init_lookups bracket_data
    lookup_game(n) || lookup_team(n)
  end

  def lookup_ancestors(g)
    begin
      init_lookups bracket_data
      @bracket_ancestors.fetch g
    rescue KeyError
      nil
    rescue => unknown
      raise BadProgrammerError(unknown)
    end
  end

  def update_team_name(name, node)
    team = lookup_team node
    team.name= name
    team.save!
    @lookup_by_label[team.class][node] = team
    self.save!
    team
  end

  def eql?(o)
    unless self.class.eql?(o.class)
      return false
    end
    self.initialization_data.zip(o.initialization_data).all? do |a|
      a[0].eql? a[1]
    end
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
        s = graph_container.label_lookup.fetch e.source
        t = graph_container.label_lookup.fetch e.target
        @bracket_ancestors[s] << t
      end
    end
  end

  def init_lookup_by_label(graph_container)
    if @lookup_by_label.nil?
      @lookup_by_label= Hash.new { |h, k| h[k] = Hash.new }
      graph_container.template_as_nodes.vertices.each do |v|
        n = graph_container.label_lookup.fetch v
        @lookup_by_label[n.class][n.label] = n
      end
    end
  end

  def init_relationships
    @lookup_by_label[Game].each do |k,v|
      v.bracket_id= self.id
      v.save!
    end
  end

end


