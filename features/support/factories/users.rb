# Read about factories at https://github.com/thoughtbot/factory_girl
FactoryGirl.define do
  factory :player, class: :user do |u|
    u.sequence(:name) { |n| 'player_'+n.to_s }
    u.email { |a| "#{a.name}@example.com" }
    u.password ENV['bogus_testing_password']
    u.password_confirmation ENV['bogus_testing_password']
    u.role 'player'
  end
end