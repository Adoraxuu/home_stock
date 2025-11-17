module Users
  class BindLineAccount
    attr_reader :error

    def initialize(bind_token:, line_user_id:, display_name: nil, picture_url: nil, status_message: nil)
      @bind_token = bind_token
      @line_user_id = line_user_id
      @display_name = display_name
      @picture_url = picture_url
      @status_message = status_message
      @error = nil
    end

    def call
      # 尋找有效的 bind_token
      line_profile = LineProfile.find_by(bind_token: @bind_token)

      unless line_profile
        @error = "找不到這個綁定碼,請重新產生"
        return false
      end

      unless line_profile.valid_bind_token?(@bind_token)
        @error = "綁定碼已過期,請重新產生"
        return false
      end

      # 檢查此 LINE 帳號是否已經綁定其他使用者
      existing_profile = LineProfile.find_by(line_user_id: @line_user_id)
      if existing_profile && existing_profile.id != line_profile.id
        @error = "此 LINE 帳號已經綁定其他使用者"
        return false
      end

      # 更新 LINE profile 資訊
      line_profile.update!(
        line_user_id: @line_user_id,
        display_name: @display_name,
        picture_url: @picture_url,
        status_message: @status_message
      )

      # 清除綁定 token
      line_profile.clear_bind_token!

      true
    rescue StandardError => e
      @error = "綁定失敗: #{e.message}"
      false
    end
  end
end
