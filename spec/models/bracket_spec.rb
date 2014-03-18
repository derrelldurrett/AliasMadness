require 'spec_helper'
require_relative '../../lib/assets/rgl/directed_adjacency_graph'

describe Bracket do

  before :all do
    @user = User.new(name: 'food',
                     password: 'foobaer',
                     password_confirmation: 'foobaer',
                     email: 'foox@bar.com',
                     role: 'player')
    @user.save!
    @user.bracket.save!
    @bracket = @user.bracket
    @reloaded_bracket = Bracket.find(@user.bracket.id)
  end
  subject { @bracket }
  describe "identity" do
    it { should be_a(Bracket) }
    it { should respond_to(:bracket_data) }
    it { should be_valid }

    #@bracket.bracket_data.depth_first_search do |v|
    #  if v.is_a? Game
    #    bracket_data.out_degree(v).should ==
    #        bracket_data.multiplicity
    #  elsif v.is_a? Team
    #    bracket_data.out_degree(v).should == 0
    #  end
    #end
    #
    #e = @bracket.bracket_data.entry_node
    #e.should be_a(Game)
    #e.label.eql?('1')
    #
    #d = @bracket.bracket_data.template_as_nodes.depth
    #d.should == 7
  end

  subject { @bracket }
  describe "serialization" do
    it { should eql(@reloaded_bracket) }
  end

  #subject { @bracket }
  #describe "Game multiplicity 2 and Team multiplicity 0" do
  #end
  #
  #describe "Game 1 is the root node" do
  #end
  #
  #describe "has depth 7" do
  #end

  let(:g1) { @bracket.lookup_game('1') }
  let(:g2) { @bracket.lookup_game('2') }
  let(:g3) { @bracket.lookup_game('3') }
  it "should do the Bracket things" do
    expect(g1).to be_a(Game)
    expect(@bracket.lookup_team('64')).to be_a(Team)
    expect(@bracket.lookup_game('63')).to be_a(Game)
    expect(@bracket.lookup_team('127')).to be_a(Team)
    expect(@bracket.lookup_node('1')).to eql @bracket.lookup_game('1')
    expect(@bracket.lookup_ancestors(g1)).to be_a(Set)
    expect(@bracket.lookup_ancestors(g1)).to include(g2)
    expect(@bracket.lookup_ancestors(g1)).to include(g3)
    expect(@reloaded_bracket.lookup_node('32').id).not_to be_nil
  end
end
