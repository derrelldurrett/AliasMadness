class Game < ActiveRecord::Base
  include HashHelper
  belongs_to :team, inverse_of: :games
  belongs_to :bracket, inverse_of: :games
  attr_accessible :label

  serialize :team, Team

  HashHelper.hash_vars= %i(id team bracket label)
  #def initialize(attributes={})
  #  super
  #  #self.hash_vars= %i(id team bracket label)
  #end

  def to_s
    to_json
  end

  def eql?(other)
    other.is_a?(Game) and label.eql? other.label and bracket.eql? other.bracket
  end
  alias == eql? # This was necessary to get the
                # comparisons to work, even though it
                # shouldn't have mattered

end
