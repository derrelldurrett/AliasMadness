class TemplateLoader
  require 'assets/rgl/directed_adjacency_graph'
  require_relative '../../app/model/concerns/errors/template_format_error'
  require_relative '../../app/models/team'
  require_relative '../../app/models/game'
  include Singleton
  attr_reader :bracket_structure_data,
              :spec_comp_regex,
              :label_lookup
  def initialize
    # Construction:
    # nNODE_NUM(a(nA_NODE1,nA_NODE2)|tT_TEAM_NUM(T_TEAM_NAME;sT_TEAM_SEED))
    @spec_comp_regex =
        Regexp.new('\An(?<node_num>\d+)\(
                    ( (?<has_a>a) \( n(?<a_node1>\d+) ; n(?<a_node2>\d+) \)
                    | (?<has_t>t)(?<team_num>\d+)
                      \( (?<team_name>[^;]+) ; s(?<team_seed>\d+) \) )
                    \)\z',
                   Regexp::EXTENDED|Regexp::MULTILINE)
  end

  def load_template(file)
    data = File.open(file) { |f| f.readlines }
    @bracket_structure_data = build_and_sort_match_data(data)
  end

  def build_and_sort_match_data(data)
    cells_as_match_data = []
    data.each do |line|
      cells = line.chomp.split(',').
          select { |cell| !cell.nil? && !cell.eql?('') }
      cells_as_match_data.concat(
          cells.map { |c| @spec_comp_regex.match(c) })
    end
    # rename compare when refactoring...
    cells_as_match_data.sort! { |a, b| compare_csv_elements a, b }
    cells_as_match_data
  end

  def build_graph(graph)
    @label_lookup = Hash.new
    # Edge is two node numbers. Lookup allows us to get from a node
    # number to the Game/Team that it represents
    edge_list = []
    @bracket_structure_data.reverse.each do |d|
      build_lookups(d, edge_list)
    end
    edge_list.reverse.each { |e| graph.add_edge e[0],e[1] }
    graph
  end

  def build_lookups(d, edge_list)
    if d[:has_a]
      (label_lookup.include?(d[:node_num]) && label_lookup.fetch(d[:node_num])) ||
          label_lookup.store(d[:node_num], new_game(d[:node_num]))
      edge_list << [d[:node_num], d[:a_node1]]
      edge_list << [d[:node_num], d[:a_node2]]
    elsif d[:has_t]
      label_lookup.store d[:node_num], get_team(d)
    else
      raise TemplateFormatError "Bad data-- node #{d} has neither a nor t"
    end
  end

  def get_team(d)
    t=Team.find_by_label(d[:node_num].to_s)
    if t.nil?
      t=Team.new({name:  d[:team_name],
                  seed:  d[:team_seed].to_i,
                  label: d[:node_num].to_s})
      t.save!
    end
    label_lookup.has_key?(d[:node_num]) || label_lookup.store(d[:node_num],d[:team_name])
    t
  end

  def new_game(node_num)
    new_g = Game.new label: node_num.to_s
    label_lookup.store node_num, new_g
    new_g
  end

  # (Meaningless) Examples:
  # n23(a(n30;n34)),
  # n12(t12(Foobar U.;s2)),
  # n14(t3(Ancillary St.;s4)),
  # n13(t5(Boofoo U.;s15))
  def compare_csv_elements(a,b)
    a[:node_num].to_i <=> b[:node_num].to_i
  end
end
