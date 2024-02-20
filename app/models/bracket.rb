# frozen_string_literal: true

class Bracket < ApplicationRecord
  require 'assets/rgl/directed_adjacency_graph'
  include Helpers::HashHelper
  extend Helpers::HashClassHelper
  include Helpers::JsonClientHelper
  extend Helpers::JsonClientClassHelper
  serialize :bracket_data, InitializeBracket::BracketTemplate
  serialize :lookup_by_label, LabelLookup
  #serialize :games, serializer: GameSerializer
  attr_accessor :bracket_data, :games
  belongs_to :user, optional: true
  after_create :init_lookups

  self.hash_vars = %i[id user]
  self.json_client_ids = %i[id nodes]

  def teams
    filter_lookups(Team)
  end

  def games
    filter_lookups(Game)
  end

  def initialization_data
    bracket_data.edges
  end

  def lookup_node(n)
    # init_lookups if lookup_by_label_uninitialized?
    self.lookup_by_label[n.to_s]
  end
  alias lookup_game lookup_node
  alias lookup_team lookup_node

  def lookup_ancestors(g)
    init_ancestors if @bracket_ancestors.nil?
    @bracket_ancestors[g.label].each_with_object(SortedSet.new) do |a, s|
      s << lookup_node(a)
    end
  end

  def update_node(content, node)
    self.lookup_by_label[node] = content
    if content.is_a? Team
      games.each do |g|
        g.winner = content if g.winner == content
      end
    end
    content
  end

  def eql?(o)
    return false unless self.class.eql?(o.class)
    initialization_data.zip(o.initialization_data).all? do |a|
      a[0].eql? a[1]
    end
  end

  def games_by_label
    @ordered_games ||= games.sort_by { |g| g.label }
  end

  def init_lookups
    init_lookup_by_label
    init_ancestors
    init_relationships
    save!
    reload
  end

  def to_json_client_string
    init_lookups
    as_json_client_data.to_json
  end

  def lookup_by_label_uninitialized?
    self.lookup_by_label.nil? or self.lookup_by_label.empty?
  end

  def to_json_ancestor_lookup_string
    init_lookups if bracket_ancestors.nil? or bracket_ancestors.empty?
    @bracket_ancestors.to_json
  end

  def bracket_data
    @bracket_data ||= BracketFactory.instance.serialized_bracket.copy
  end

  private

  attr_reader :bracket_ancestors

  def filter_lookups(clazz)
    init_lookups if lookup_by_label_uninitialized?
    self.lookup_by_label.filter { |_l, n| n.is_a? clazz }.values
  end

  def find_or_init_team(n)
    TeamFactory.instance.find_or_create_team(**n)
  end

  def find_or_init_game(n)
    GameFactory.instance.find_or_create_game(**n)
  end

  def init_ancestors
    if @bracket_ancestors.nil? or @bracket_ancestors.empty?
      @bracket_ancestors = Hash.new { |h, k| h[k] = SortedSet.new }
      bracket_data.edges.each do |e|
        @bracket_ancestors[e.source] << e.target
      end
    end
  end

  def init_lookup_by_label
    if lookup_by_label_uninitialized?
      self.lookup_by_label = LabelLookup.new
      init_lookups_from_template
    end
  end

  def init_lookups_from_template
    bracket_data.vertices.each do |v|
      n = bracket_data.label_lookup.fetch v
      init_node(n)
    end
  end

  def init_node(n)
    n = n.key?(:name) ? find_or_init_team(n) : find_or_init_game(n)
    update_node(n, n.label.to_s)
  end

  def init_relationships
    if @games.nil? or @games.empty?
      game_ids = []
      my_games = []
      self.lookup_by_label.each_value do |v|
        next unless v.is_a? Game

        game_ids << v.id
        my_games << v
      end
      @games = my_games
    end
  end

  # part of the to_json_client_string pile
  def nodes
    r = []
    bracket_data.vertices.each do |v|
      r << self.lookup_by_label[v].as_json_client_data
    end
    r
  end
end
