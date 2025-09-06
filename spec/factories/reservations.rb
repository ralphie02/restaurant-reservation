FactoryBot.define do
  factory :reservation do
    party_size { 2 }
    start_time { Time.now.change(hour: 12) }
    duration { 1 }
    period { start_time..(start_time + duration.hours) }
    table
  end
end
