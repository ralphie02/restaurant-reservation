FactoryBot.define do
  factory :restaurant do
    name { "resto#{rand(1000)}" }
  end
end
