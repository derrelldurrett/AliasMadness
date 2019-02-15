# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :game do
    team nil
    bracket nil
    label "MyString"
  end
end
