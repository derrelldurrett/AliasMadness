# frozen_string_literal: true

class Team
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include Helpers::HashHelper
  extend Helpers::HashClassHelper
  include Helpers::JsonClientHelper
  extend Helpers::JsonClientClassHelper

  self.hash_vars= %i(name seed id)
  self.json_client_ids= [:id, :label, :name, :seed, :eliminated]

  attr_accessor :id, :label, :name, :seed, :eliminated, :name_locked
  alias :eliminated? :eliminated
  alias :name_locked? :name_locked

  def to_s
    "#{name} (#{seed})"
  end

  # Team's clone is itself (Teams are unique, uncopyable)
  def clone
    self
  end
  alias dup clone

  def eql?(other)
    other.is_a? Team and name == other.name and seed == other.seed
  end
  alias == eql?

  def <=>(other)
    label <=> other.label
  end

  private

  def allowed_params
    params.require(:team).permit(%i[label name seed eliminated])
  end
end
