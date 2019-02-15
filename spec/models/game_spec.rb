require 'spec_helper'
require_relative '../../app/models/bracket'

describe Game do
  context 'interface' do
    it {should respond_to(:team)}
    it {should respond_to(:label)}
  end

  game1 = Game.new
  game1.update(label: '1')
  game2 = Game.new
  game2.update(label: '2')
  subject { game1 }
  context 'hashing' do
    it {should_not eql game2}
  end
end
