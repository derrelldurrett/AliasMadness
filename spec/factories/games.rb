# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :game do
    label {"MyString"}
    team {nil}
    bracket {nil}
  end
end
