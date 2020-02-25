require_relative '../test_constants'
FactoryBot.define do
  factory :player, class: User do
    sequence(:name) { |n| 'player '+n.to_s } # the space so that tests can have to uniquify chat names
    sequence(:email) { |n| "person#{n}@example.com" }
    password {$my_fake_password}
    password_confirmation {$my_fake_password}
    role {:player}
  end
end
