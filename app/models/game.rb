# frozen_string_literal: true

class Game
  extend ActiveModel::Naming
  include ActiveModel::Conversion
  include Helpers::HashHelper
  extend Helpers::HashClassHelper
  include Helpers::JsonClientHelper
  extend Helpers::JsonClientClassHelper

  attr_accessor :id, :label, :winner, :winners_label, :locked

  self.hash_vars= %i(id team label)
  self.json_client_ids= %i(id label winner winners_label locked)
  def to_s
    to_json
  end

  def <=> (o)
    label <=> o.label
  end

  def eql?(other)
    other.is_a?(Game) and label.eql? other.label
  end
  alias == eql?

  alias team winner

  def team=(t)
    raise(ArgumentError, "#{t} is not a Team object") unless t.is_a? Team
    self.team = t
  end

  def winners_label
    winner.nil? ? nil : winner.label
  end

  def ancestors
    bracket.lookup_ancestors(self)
  end

  def round_multiplier
    mult ||= case label.to_i
             when 1      then 64
             when 2..3   then 32
             when 4..7   then 16
             when 8..15  then 8
             when 16..31 then 4
             when 32..63 then 2
             else
               raise StandardError, "broken game label: #{label}"
             end
    mult
  end

  def round
    r ||= case label.to_i
          when 1      then 6
          when 2..3   then 5
          when 4..7   then 4
          when 8..15  then 3
          when 16..31 then 2
          when 32..63 then 1
          else raise StandardError, "broken game label: #{label}"
          end
    r
  end

  def last_in_round?
    l ||= case label.to_i
          when 1, 2, 4, 8, 16, 32 then true
          else false
          end
  end
end
