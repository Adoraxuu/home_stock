module Line
  class WebhookProcessor
    def initialize(event)
      @event = event
    end

    def process
      # 只處理訊息事件
      return unless @event["type"] == "message"
      return unless @event["message"]["type"] == "text"

      line_user_id = @event["source"]["userId"]
      message_text = @event["message"]["text"]

      # 解析訊息
      parsed_command = Line::MessageParser.new(message_text).parse

      # 根據指令類型執行對應動作
      case parsed_command[:action]
      when :bind
        handle_bind(line_user_id, parsed_command[:token])
      when :add, :remove, :set
        handle_inventory_command(line_user_id, parsed_command)
      when :query
        handle_query(line_user_id, parsed_command[:name])
      when :list
        handle_list(line_user_id)
      when :unknown
        handle_unknown(line_user_id, parsed_command[:text])
      end
    end

    private

    def handle_bind(line_user_id, token)
      # 取得 LINE 使用者資訊
      # TODO: 實際呼叫 LINE API 取得使用者資訊
      display_name = "LINE User"  # 暫時使用預設值

      service = Users::BindLineAccount.new(
        bind_token: token,
        line_user_id: line_user_id,
        display_name: display_name
      )

      if service.call
        reply_message(line_user_id, "綁定成功!👌\n現在你可以開始管理家庭庫存了")
      else
        reply_message(line_user_id, service.error)
      end
    end

    def handle_inventory_command(line_user_id, command)
      # 先檢查使用者是否已綁定
      line_profile = LineProfile.find_by(line_user_id: line_user_id)
      unless line_profile&.bound?
        reply_message(line_user_id, "請先綁定帳號才能使用庫存功能喔!\n\n請到網頁版取得綁定碼,然後傳送:\n綁定 [綁定碼]")
        return
      end

      # TODO: 實作庫存指令處理
      reply_message(line_user_id, "庫存功能開發中...")
    end

    def handle_query(line_user_id, item_name)
      # TODO: 實作查詢功能
      reply_message(line_user_id, "查詢功能開發中...")
    end

    def handle_list(line_user_id)
      # TODO: 實作列表功能
      reply_message(line_user_id, "列表功能開發中...")
    end

    def handle_unknown(line_user_id, text)
      help_text = <<~TEXT
        我還不太懂這個指令耶 🤔

        目前支援的指令:
        • 綁定 [綁定碼] - 綁定帳號
        • +品名 數量 - 新增庫存
        • -品名 數量 - 減少庫存
        • 設 品名 數量 - 設定數量
        • 查 品名 - 查詢庫存
        • 庫存 - 查看所有庫存
      TEXT

      reply_message(line_user_id, help_text)
    end

    def reply_message(line_user_id, text)
      # TODO: 實際呼叫 LINE Messaging API 回覆訊息
      Rails.logger.info "Reply to #{line_user_id}: #{text}"
    end
  end
end
