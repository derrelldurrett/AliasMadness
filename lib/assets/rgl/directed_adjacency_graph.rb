require 'rgl/base'
require 'rgl/adjacency'
require 'rgl/traversal'

# Monkey patch it
class RGL::DirectedAdjacencyGraph
  attr_reader :entry_node, :vertices_dict

  def to_s
    if @vertices_dict.nil?
      'nil'
    else
      edges.to_ary.to_s
    end
  end

  # The graph constructor is an array of edges, which is
  # really an array of two-element arrays where the two
  # elements are the ordered vertices
  def json_serialization_list
    ret = []
    edges.each do |e|
      a = e.to_a
      ret << [a[0].to_json, a[1].to_json]
    end
    ret
  end

  def depth
    # memoize
    @depth ||= compute_depth
  end

  def multiplicity
    # memoize
    @multiplicity ||=
        out_degree(vertices.max_by {|v| out_degree(v)})
  end

  def copy
    # self is the original, copy is what we return
    copy = RGL::DirectedAdjacencyGraph.new
    attach_vertex_lookup
    each_edge do |u,v|
      x = lookup_cloned_vertices u
      y = lookup_cloned_vertices v
      copy.add_edge x,y
    end
    #copy.depth
    copy
  end

  # Two graphs are equal iff they have the same collection
  # of edges and vertices
  def eql?(other)
    self.class.eql?(other.class) and
        edges.eql? other.edges and
        vertices.eql? other.vertices
  end

  def handle_examine_vertex(v)
    super
    @waiting.push(v)
  end

  def iterator
    if !@iterator.nil? && @iterator.at_beginning?
      @iterator
    else
      @iterator ||= instantiate_iterator
      @iterator.set_to_begin && @iterator
    end
  end

  def self.load(serialization)
    _edges = Array.load(serialization)
    RGL::DirectedAdjacencyGraph _edges
  end

  def dump
    YAML.dump edges.to_ary
  end

  private

  def compute_depth
    dfs_it = dfs_iterator(identify_root_node)
    dfs_it.attach_distance_map
    attach_depth_map
    @depth = dfs_it.distance_to_root(
        dfs_it.max_by do |v|
          d = dfs_it.distance_to_root(v)
          add_vertex_by_depth(d,v)
          d
        end
    )
    @depth
  end

  def attach_vertex_lookup(map = Hash.new)
    @cloned_vertices ||= map

    # a neat little trick to create a closure
    # for @cloned_vertices
    class << self
      # Stores the vertex/clone pair if not done,
      # returns clone in all cases.
      def lookup_cloned_vertices(vertex)
        @cloned_vertices[vertex] ||
            @cloned_vertices.store(vertex,vertex.clone)
      end
    end
  end

  def attach_depth_map(map = Hash.new() {|h,k| h[k] = Set.new})
    @depth_map ||= map

    class << self
      def lookup_vertices_by_depth(d)
        @depth_map[d] #.to_a.sort_by! {}
      end

      def add_vertex_by_depth(d, v)
        @depth_map[d] << v
        c = v.class
      end
    end

    def depth_map(d)
      @depth_map[d]
    end
  end

  def identify_root_node
    @entry_node ||= vertices.detect do |n|
      n.is_a? Game and n.label.eql? %q(1)
    end
  end


  def instantiate_iterator
    @iterator ||= dfs_iterator(identify_root_node)
  end

end
