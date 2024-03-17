# frozen_string_literal: true

class GameSerializer < ActiveModel::Serializer
  attributes :id, :label, :winner, :winners_label # Add other attributes as needed
end