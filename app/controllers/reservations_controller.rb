class ReservationsController < ApplicationController
  before_action :check_idempotency_key

  def create
    @reservation = Reservation.find_or_initialize_by(idempotency_key: request.headers['Idempotency-Key'])
    return render json: @reservation, status: :ok if @reservation.persisted?

    if CreateReservation.call(params: reservation_params, reservation: @reservation)
      render json: @reservation, status: :created
    else
      render json: { errors: @reservation.errors.full_messages }, status: :unprocessable_content
    end
  end

  private

  def check_idempotency_key
    head :bad_request if request.headers['Idempotency-Key'].blank?
  end

  def reservation_params
    params.require(:reservation).permit(:party_size, :duration, :start_time)
  end
end
