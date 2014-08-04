require 'helpers/hash_helper'
class Team < ActiveRecord::Base
  include HashHelper
  attr_accessible :label, :name, :seed
  has_many :games, inverse_of: :teams
  validates :name, uniqueness: true
  validates :seed, numericality: {only_integer: true}

  HashHelper.hash_vars= %i(name seed id)

  # Team's clone is itself (Teams are unique, uncopyable)
  def clone
    self
  end
  alias dup clone

  def eql?(other)
#    other.is_a? Team and puts other.name
    other.is_a? Team and ((object_id==other.object_id) or (name == other.name and
        seed == other.seed))

  end
  alias == eql?

end
