class Team < ActiveRecord::Base
  attr_accessible :label, :name, :seed
  validates :name, uniqueness: true

  # Expect this to bite us in the ass regarding to_json()
  def to_s
    "#{name} (#{seed})"
  end

  # Team's clone is itself (Teams are unique, uncopyable)
  def clone
    self
  end
  alias dup clone

  def eql?(other)
    other.is_a? Team and
    name == other.name and
        seed == other.seed
  end

  alias == eql?

end
