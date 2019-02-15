# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :bracket do
    belongs_to ""
    bracket_data "MyText"
    lookup_by_label "MyText"
  end
end
