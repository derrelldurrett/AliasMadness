# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :user do
    name "MyString"
    email 'my@emacil.com'
    p= SecureRandom.base64(24)
    password p
    password_confirmation p
  end
end
