module Line
  class WebhooksController < ApplicationController
    skip_before_action :verify_authenticity_token

    def callback
      body = request.body.read
      signature = request.env["HTTP_X_LINE_SIGNATURE"]

      # 驗證 LINE 簽章
      unless verify_signature(body, signature)
        Rails.logger.warn "Invalid LINE signature"
        return head :bad_request
      end

      # 解析事件
      events = JSON.parse(body)["events"] || []

      events.each do |event|
        Line::WebhookProcessor.new(event).process
      end

      head :ok
    rescue JSON::ParserError => e
      Rails.logger.error "Invalid JSON from LINE webhook: #{e.message}"
      head :bad_request
    end

    private

    def verify_signature(body, signature)
      return true if Rails.env.development? && LINE_CONFIG[:channel_secret].blank?

      line_client = Line::Client.new
      line_client.validate_signature(body, signature)
    end
  end
end
