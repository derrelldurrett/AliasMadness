class BracketSerializer < ActiveModel::Serializer
  attributes :id, :user, :lookup_by_label, :bracket_data
end
