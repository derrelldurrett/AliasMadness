# frozen_string_literal: true
require 'helpers/hash_helper'
require 'helpers/hash_class_helper'
require 'helpers/json_client_helper'
require 'helpers/json_client_class_helper'
class Game < ApplicationRecord
  include HashHelper
  extend HashClassHelper
  include JSONClientHelper
  extend JSONClientClassHelper
  belongs_to :team, inverse_of: :games, optional: true
  belongs_to :bracket, inverse_of: :games, optional: true

  serialize :team, Team

  self.hash_vars= %i(id team bracket label)
  self.json_client_ids= [:id, :label, :winner, :winners_label]
  def to_s
    to_json
  end

  def channel
    GameUpdaterChannel.broadcasting_for self
  end

  def eql?(other)
    other.is_a?(Game) and label.eql? other.label and bracket.eql? other.bracket
  end
  alias == eql? # This was necessary to get the
                # comparisons to work (even though it
                # shouldn't have mattered?)

  alias winner team
  alias winner= team=

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
