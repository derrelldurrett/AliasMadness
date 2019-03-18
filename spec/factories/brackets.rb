# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :bracket do
    bracket_data {"MyText"}
    lookup_by_label {"MyText"}
    user
  end
end
