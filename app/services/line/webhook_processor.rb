module Line
  class WebhookProcessor
    def initialize(event, reply_token: nil)
      @event = event
      @reply_token = reply_token || event["replyToken"]
      @line_client = Line::Client.new
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

    # 檢查使用者是否已綁定,並回傳 user
    def check_binding(line_user_id)
      line_profile = LineProfile.find_by(line_user_id: line_user_id)
      unless line_profile&.bound?
        reply_message("請先綁定帳號才能使用庫存功能喔!\n\n請到網頁版取得綁定碼,然後傳送:\n綁定 [綁定碼]")
        return nil
      end
      line_profile.user
    end

    def handle_bind(line_user_id, token)
      # 取得 LINE 使用者資訊
      profile = @line_client.get_profile(line_user_id)

      service = Users::BindLineAccount.new(
        bind_token: token,
        line_user_id: line_user_id,
        display_name: profile&.dig("displayName"),
        picture_url: profile&.dig("pictureUrl"),
        status_message: profile&.dig("statusMessage")
      )

      if service.call
        reply_message("綁定成功!👌\n現在你可以開始管理家庭庫存了")
      else
        reply_message(service.error)
      end
    end

    def handle_inventory_command(line_user_id, command)
      user = check_binding(line_user_id)
      return unless user

      item_name = command[:name]
      quantity = command[:quantity]

      service = case command[:action]
      when :add
        Inventory::AddItem.new(user: user, item_name: item_name, quantity: quantity, source: "line_bot")
      when :remove
        Inventory::RemoveItem.new(user: user, item_name: item_name, quantity: quantity, source: "line_bot")
      when :set
        Inventory::SetQuantity.new(user: user, item_name: item_name, quantity: quantity, source: "line_bot")
      end

      if service.call
        reply_message(service.success_message)
      else
        reply_message(service.error)
      end
    end

    def handle_query(line_user_id, item_name)
      user = check_binding(line_user_id)
      return unless user

      service = Inventory::QueryItem.new(user: user, item_name: item_name)
      items = service.call

      if items
        reply_message(service.format_response(items))
      else
        reply_message(service.error)
      end
    end

    def handle_list(line_user_id)
      user = check_binding(line_user_id)
      return unless user

      service = Inventory::ListItems.new(user: user)
      items = service.call

      if items
        reply_message(service.format_response(items))
      else
        reply_message(service.error)
      end
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

      reply_message(help_text)
    end

    def reply_message(text)
      return unless @reply_token

      response = @line_client.reply_message(@reply_token, text)
      Rails.logger.info "LINE reply sent: #{response.code}" if response
    end
  end
end
