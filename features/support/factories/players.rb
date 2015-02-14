require_relative '../test_constants'
FactoryGirl.define do
  factory :player, class: User do
    sequence(:name) { |n| 'player'+n.to_s }
    sequence(:email) { |n| "person#{n}@example.com" }
    password $my_fake_password
    password_confirmation $my_fake_password
    role :player
  end

end
