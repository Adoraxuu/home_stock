require "line/bot"

module Line
  class Client
    def initialize
      @client = ::Line::Bot::Client.new do |config|
        config.channel_secret = LINE_CONFIG[:channel_secret]
        config.channel_token = LINE_CONFIG[:channel_token]
      end
    end

    # 回覆訊息
    def reply_message(reply_token, message)
      return false if LINE_CONFIG[:channel_token].blank?

      @client.reply_message(reply_token, {
        type: "text",
        text: message
      })
    end

    # 推送訊息
    def push_message(user_id, message)
      return false if LINE_CONFIG[:channel_token].blank?

      @client.push_message(user_id, {
        type: "text",
        text: message
      })
    end

    # 取得使用者資訊
    def get_profile(user_id)
      return nil if LINE_CONFIG[:channel_token].blank?

      response = @client.get_profile(user_id)
      return nil unless response.is_a?(Net::HTTPSuccess)

      JSON.parse(response.body)
    end

    # 驗證簽章
    def validate_signature(body, signature)
      return false if LINE_CONFIG[:channel_secret].blank?

      @client.validate_signature(body, signature)
    end
  end
end
