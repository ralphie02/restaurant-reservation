# README

## Requirments
    - Rails 8
    - Ruby 3.3.7
    - PSQL
## How to run
    - git clone git@github.com:ralphie02/restaurant-reservation.git
    - run bundle
    - rake db:create + rake db:migrate + rake db:seed
    - rails s
## API Testing (used insomnia)
    - (request) GET - localhost:3000/tables/occupied
        - params
          ```json
          // seed file generates 2 reservations at "2026-01-01 12:00:00 -0800"
          { "at": "2026-01-01 12:00:00 -0800" }
          ```
        - response
          ```json
        {
          "tables": [
            {
              "id": 2,
              "capacity": 2,
              "reservation_id": 1,
              "party_size": 2
            },
            {
              "id": 3,
              "capacity": 4,
              "reservation_id": 2,
              "party_size": 4
            }
          ]
}
          ```
    - (request) POST - localhost:3000/reservations
        - header param
            - "Idempotency-Key" = random-string
        - body
          ```json
        {
            "party_size": 8,
            "duration": 1,
            "start_time": "2025-09-07T13:30:00Z"
        }
          ```
        - response
          ```json
        {
          "id": 4,
          "table_id": 5,
          "party_size": 8,
          "duration": "1.0",
          "start_time": "2025-09-07T13:30:00.000Z",
          "period": "2025-09-07 13:30:00 UTC...2025-09-07 14:30:00 UTC",
          "idempotency_key": "2",
          "created_at": "2025-09-06T17:56:22.036Z",
          "updated_at": "2025-09-06T17:56:22.036Z"
        }
          ```
## Design overview
    - To handle complexity, I chose Service Object Pattern since I only really have 2 main services:
        - CreateReservation to handle reservation creation logic
        - AllocateTable to handle the strategy in allocating a table during a POST reservation request
    - AllocateTable takes the brunt of the application's business logic. As mentioned in the requirements, this is something that can/designed to be swapped if necessary.
    - CreateReservation should contain any additional validation if necessary (at least, that was my intention). In addition, as per my TODO, any additional error handling should be placed here
## Test Strategy
    - For the most part, my testing is reflected in the spec files; I also did a bunch of manual testing as I built the app logic which will be seen below
## Manual Testing
    - Idempotency-Key
        - Without key - 400 Bad Request
        - With key
            - 201 created when a new reservation is generated
            - 200 ok when it's a "duplicate request"/the request already succeeded previously
    - POST
        - Happy path - 201 created and app responds with the reservation object
        - Unhappy path
            - 422 "No available table"
            - I skipped testing bad, malformed data...
        - I also tested to ensure that no reservation overlaps via both DB and App level by trying to create a reservation on a table using a period of an existing reservation.
    - GET
        - Happy path - 200 ok
        - Unhappy path - no testing on bad malformed data
    - Reservation
        - As mentioned, I tested to ensure no overlapping reservations
        - Ensure no reservation is created when party_size is larger than the table's capacity
## Stretch Goals
    - Better Allocation
        - Not sure if my implementation is "better" acceptable for this point but it does take the smallest table first, if available.
        - It is somewhat complex due to the subquery to capture reservations within the specified period, which uses tsrange as mentioned in the other stretch goal
        - I utilized half-open for the tsrange so  reservation periods such as 12-14:00 and 14-16 should not overlap
        - I think the biggest issue/edge case for this logic is the inability to combine tables. I opted to skip this because, realistically, this needs a lot more information such as restaurant orientation to determine the table layout which determines how the tables can be combined. Overall, this is a little too complex and I think is somewhat beyond the suggest timebox for this app.
    - DB-level Safety
        - I opted to use tsrange.
        - One issue might be timezone but that's something that I skipped by choice since time in general is hard and it's beyond the scope of this project.
    - Resilience
        - I opted to skip this but left a TODO in CreateReservation service on how I would handle this
    - Observability
        - Skipped. I'm not exactly sure how I would structure the logs myself + no time.
    - Performance
        - I added index for idempotency-key which should be quite significant if significant instance of duplicate requests are made.
        - I also added an index for the table_id and period on a reservation since almost every request for reservations will always involve a table and a period.
    - Policy Constraints
        - Skipped. Seems very business logic heavy + no time
## AI Usage
    - Prompt (via chatgpt)
        - "How to write Rails model validation AND psql constraint so tsrange do not overlap. For example, if an Event record with active_period exist for "2025-10-01 12:00:00" for 2 hours (so 2025-10-01 12:00:00 -0700..2025-10-01 14:00:00 -0700), don't create another an event for "2025-10-01 13:00:00 -0700..2025-10-01 15:00:00 -0700"
      ```ruby
        # code 1 - db migration
        class AddNoOverlapConstraintToEvents < ActiveRecord::Migration[7.1]
          def change
            # Ensure btree_gist extension is available (needed for exclusion constraints)
            enable_extension "btree_gist"
            add_exclusion_constraint :events, "active_period WITH &&", using: :gist, name: "no_overlapping_events"
          end
        end

        # code 2 - suggestion from chatgpt
        # If you want the constraint to only apply **per room / resource**, you can add a column like `room_id`:
        add_exclusion_constraint :events, "room_id WITH =, active_period WITH &&", using: :gist, name: "no_overlapping_events_per_room"

        # code 3 - sample model
        class Event < ApplicationRecord
          validate :active_period_does_not_overlap

          private

          def active_period_does_not_overlap
            return unless active_period.present?

            overlap = Event.where("active_period && tsrange(?, ?)", active_period.begin, active_period.end)
            overlap = overlap.where.not(id: id) if persisted? # ignore self when updating

            if overlap.exists?
              errors.add(:active_period, "overlaps with another event")
            end
          end
        end
      ```
    - The query for AllocateTable is the other help I got from AI. I don't remember the actual prompt but it was a bit of a back and forth with chatgpt
    - For the most part, I used the code from chatgpt to build AllocateTable and the overlapping validation in Reservation model. I also ask copilot to help build the spec skeleton for me then mostly remove the body....
    - AI snippets that I kept
        - reservation.rb line 13
        - allocate_table.rb - line 7 (it's mostly the subquery)
        - table.rb - line 8 'where("reservations.period @> ?::timestamp", timestamp)' since I didn't know how to properly query a period with a timestamp - I had to typecast
## Assumptions
    - This app only works with 1 restaurant at the moment so I mostly just pick the first one. I wasn't sure in the beginning why there's a restaurant entity but I'm guessing the app is supposed to handle multiple restaurants but since there was no mention of how to select a restaurant, I opted to skip that logic altogether.
    - Param request data always have the correct format
