# Read about factories at https://github.com/thoughtbot/factory_bot
FactoryBot.define do
  factory :user do
    name {"MyString"}
    email {'my@emacil.com'}
    current_score {0}
  end

  sequence :random_name do |n|
    "some_player_#{n}"
  end

  sequence :random_email do |n|
    "player_#{n}@foo.bar"
  end

  factory :random_user, class: "User" do
    name {generate :random_name}
    email {generate :random_email}
    password {'some useless password'}
    password_confirmation {'some useless password'}
    role {:player}
    current_score {0}
  end

  factory :admin, class: "User" do
    name {'admin'}
    email {'admin@foo.bar'}
    password {'some useless password'}
    password_confirmation {'some useless password'}
    role {:admin}
  end
end
