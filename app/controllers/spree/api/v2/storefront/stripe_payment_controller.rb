# frozen_string_literal: true

module Spree
  module Api
    module V2
      module Storefront
        class StripePaymentController < ::Spree::Api::V2::BaseController
          def create
            order = Spree::Order.find(params[:order_id])
            
            payment_method = Spree::PaymentMethod.find_by(type: 'Spree::Gateway::Bogus')

            bogus_card = Spree::CreditCard.create!(
              number: '4111111111111111',  # Dummy card number
              month: '12',
              year: '2025',
              verification_value: '123',
              name: 'Bogus Card',
              payment_method: payment_method,
              user_id: order.user_id
            )

            payment = order.payments.build(
              payment_method_id: payment_method.id,
              amount: order.total,
              source: bogus_card,  # Ensure source is present
              state: 'checkout'    # Initial state, adjust as necessary
            )

            begin
              if payment.save
                if payment.state == 'checkout'
                  payment.pend!
                end

                render json: { message: 'Payment created successfully' }, status: :ok
              else
                render json: { error: 'Payment could not be completed' }, status: :unprocessable_entity
              end
            rescue StateMachines::InvalidTransition => e
              render json: { error: e.message }, status: :unprocessable_entity
            rescue StandardError => e
              render json: { error: e.message }, status: :unprocessable_entity
            end
          end
        end
      end
    end
  end
end
