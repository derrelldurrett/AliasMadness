# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryBot.define do
  factory :user do
    name "MyString"
    email 'my@emacil.com'
    current_score 0
  end
end
