require 'helpers/hash_helper'
require 'helpers/hash_class_helper'
require 'helpers/json_client_helper'
require 'helpers/json_client_class_helper'
class Team < ActiveRecord::Base
  include HashHelper
  extend HashClassHelper
  include JSONClientHelper
  extend JSONClientClassHelper
  attr_accessible :label, :name, :seed, :eliminated
  has_many :games, inverse_of: :teams
  validates :name, uniqueness: true
  validates :seed, numericality: {only_integer: true}

  self.hash_vars= %i(name seed id)
  self.json_client_ids= [:id, :label, :name, :seed, :eliminated]

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
