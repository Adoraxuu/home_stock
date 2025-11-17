module Line
  class WebhooksController < ApplicationController
    skip_before_action :verify_authenticity_token
    skip_before_action :authenticate_user!

    def callback
      # TODO: 驗證 LINE 簽章
      # body = request.body.read
      # signature = request.env['HTTP_X_LINE_SIGNATURE']
      # unless verify_signature(body, signature)
      #   return head :bad_request
      # end

      events = params[:events] || []

      events.each do |event|
        Line::WebhookProcessor.new(event).process
      end

      head :ok
    end

    private

    def verify_signature(body, signature)
      # TODO: 實作 LINE 簽章驗證
      # hash = OpenSSL::HMAC.digest(OpenSSL::Digest.new('SHA256'), ENV['LINE_CHANNEL_SECRET'], body)
      # Base64.strict_encode64(hash) == signature
      true
    end
  end
end
