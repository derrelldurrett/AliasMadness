FactoryGirl.define do
  factory :player, class: User do
    sequence(:name) { |n| 'player'+n.to_s }
    sequence(:email) { |n| "person#{n}@example.com" }
    current_score 0
    role :player
  end

end
