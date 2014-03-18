require 'spec_helper'

describe Game do
  before(:all) do
      raise 'fail!'
    bracket = Bracket.first!
    @game1 = bracket.lookup_game('1')
    @game2 = bracket.lookup_game('2')
    @game3 = bracket.lookup_game('3')
  end

  context 'interface' do
    it {should respond_to(:team)}
    it {should respond_to(:label)}
  end

  subject { @game1 }
  context 'hashing' do
    it {should_not eql @game2}
    second_game1 = Game.find(@game1.id)
    it {should eql second_game1}
  end
end
