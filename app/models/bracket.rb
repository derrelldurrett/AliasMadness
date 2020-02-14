# frozen_string_literal: true

require 'assets/rgl/directed_adjacency_graph'
require 'initialize_bracket/bracket_template'
require 'helpers/hash_helper'
require 'helpers/hash_class_helper'
require 'helpers/json_client_helper'
require 'helpers/json_client_class_helper'
class Bracket < ApplicationRecord
  @@cached_teams = []
  include HashHelper
  extend HashClassHelper
  include JSONClientHelper
  extend JSONClientClassHelper
  serialize :bracket_data, BracketTemplate
  serialize :lookup_by_label, Hash
  attr_accessor :bracket_data
  belongs_to :user, optional: true
  has_many :games, inverse_of: :bracket
  after_find :init_lookups
  after_initialize :init_lookups

  self.hash_vars = %i[id user]
  self.json_client_ids = %i[id nodes]

  def teams
    @@cached_teams.empty? and init_cached_teams
    @@cached_teams
  end

  def init_cached_teams
    init_lookups if lookup_by_label_uninitialized?
    lookup_by_label.each do |_l, n|
      @@cached_teams << n if n.is_a?(Team)
    end
  end

  def teams_attributes=(name)
    puts "Got attributes: #{name}"
  end

  def initialization_data
    bracket_data.edges
  end

  def lookup_game(l)
    # This probably can change to not always look at the DB
    g= Game.where(bracket_id: self.id, label: l).first
  end

  def lookup_node(n)
    init_lookups if lookup_by_label_uninitialized?
    lookup_by_label[n.to_s]
  end

  def lookup_ancestors(g)
    bracket_data.vertices_dict.fetch(g.label).map do |l|
      lookup_node(l)
    end
  end

  def update_node(content, node)
    # old_content= @lookup_by_label[node]
    @lookup_by_label[node] = content
    content
  end

  def eql?(o)
    return false unless self.class.eql?(o.class)
    initialization_data.zip(o.initialization_data).all? do |a|
      a[0].eql? a[1]
    end
  end

  def games_by_label
    @ordered_games ||= games.order('label').to_a
  end

  def init_lookups
    init_lookup_by_label# if lookup_by_label_uninitialized?
    init_ancestors
    init_relationships
  end

  def to_json_client_string
    init_lookups
    as_json_client_data.to_json
  end

  def lookup_by_label_uninitialized?
    lookup_by_label.nil? or lookup_by_label.empty?
  end

  def to_json_ancestor_lookup_string
    init_lookups if bracket_ancestors.nil? or bracket_ancestors.empty?
    @bracket_ancestors.to_json
  end

  def newest_game_date
    # TODO: turn this into a SQL statement on the bracket returning the most
    # recent game
    Game.where(bracket_id: id)
  end

  def bracket_data
    @bracket_data ||= BracketFactory.instance.serialized_bracket.copy
  end

  private

  attr_reader :lookup_by_label, :bracket_ancestors

  def find_or_init_team(n)
    t = Team.find_by(label: n[:label])
    n[:name_locked] = false
    n[:eliminated] = false
    t = Team.create(n) if t.nil?
    t
  end

  def find_or_init_game(n)
    n.is_a?(Game) ? n : init_game(n[:label])
  end

  def init_ancestors
    if @bracket_ancestors.nil? or @bracket_ancestors.empty?
      @bracket_ancestors = Hash.new { |h, k| h[k] = SortedSet.new }
      bracket_data.edges.each do |e|
        @bracket_ancestors[e.source] << e.target
      end
    end
  end

  def init_game(label)
    Game.find_or_create_by(label: label.to_s, bracket_id: id, locked: false)
  end

  def init_lookup_by_label
    if lookup_by_label_uninitialized?
      @lookup_by_label ||= {}
      if id.nil? or games.empty?
        init_lookups_from_template
      else
        init_lookups_from_database
      end
    end
  end

  def init_lookups_from_template
    bracket_data.vertices.each do |v|
      n = bracket_data.label_lookup.fetch v
      init_node(n)
    end
  end

  def init_lookups_from_database
    if lookup_by_label_uninitialized?
      @lookup_by_label ||= {}
      games.each do |g|
        @lookup_by_label[g.label] = g
      end
      Team.all.each do |t|
        @lookup_by_label[t.label] = t
      end
    end
    init_ancestors unless bracket_data.nil?
  end

  def init_node(n)
    n = n.key?(:name) ? find_or_init_team(n) : find_or_init_game(n)
    @lookup_by_label[n.label.to_s] = n
  end

  def init_relationships
    game_ids = []
    my_games = []
    lookup_by_label.each_value do |v|
      next unless v.is_a? Game

      v.save! if v.id.nil?
      game_ids << v.id
      my_games << v
    end
    if id.nil?
      self. games = my_games
    else
      Game.where(id: game_ids).update_all(bracket_id: id)
    end
  end

  # part of the to_json_client_string pile
  def nodes
    r = []
    bracket_data.vertices.each do |v|
      r << lookup_by_label[v].as_json_client_data
    end
    r
  end
end
