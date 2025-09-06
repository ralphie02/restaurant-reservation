class CreateReservation
  def self.call(...)
    new(...).call
  end

  def initialize(params:, reservation:)
    @reservation = reservation
    @party_size = params[:party_size].to_i
    @duration = params[:duration].to_i
    @start_time = Time.parse(params[:start_time])
    @period = start_time...(start_time + duration.hours)
  end

  def call
    reservation.errors.add(:base, "No available table") and return if table.blank?

    assign_attributes
    reservation.save
    # TODO:
    # Add rescue ActiveRecord::RecordInvalid for race condition when another attempt
    # to create a reservation is requested.
    # Inside rescue, raise another error then rescue in the controller to render 409
    # as mentioned in the requirements.
    # TODO:
    # Handle bad data (eg. Time.parse(<bad_data>)
  end

  private

  attr_reader :party_size, :duration, :start_time, :period, :reservation

  def assign_attributes
    reservation.assign_attributes(
      party_size: party_size,
      duration: duration,
      start_time: start_time,
      period: period,
      table: table
    )
  end

  # Update with a different service to allocate table differently
  #
  def table
    @table ||= AllocateTable.call(party_size: party_size, period: period)
  end
end
