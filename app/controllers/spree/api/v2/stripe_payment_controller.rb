# frozen_string_literal: true

module Spree
  module Api
    module V2
      class StripePaymentController < ::Spree::Api::V2::BaseController
        def create
          order = Spree::Order.find(params[:order_id])
          payment_method = Spree::PaymentMethod.find_by(type: 'Spree::Gateway::StripeElementsGateway')

          payment = order.payments.build(
            payment_method_id: payment_method.id,
            amount: order.total,
            intent_client_key: params[:intent_client_key],
            state: 'checkout'
          )

          if payment.process!
            render json: { message: 'Payment created successfully' }, status: :ok
          else
            render json: { error: 'Error in processing payment' }, status: :unprocessable_entity
          end
        end
      end
    end
  end
end
