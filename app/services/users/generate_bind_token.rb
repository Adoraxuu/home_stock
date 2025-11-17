module Users
  class GenerateBindToken
    def initialize(user)
      @user = user
    end

    def call
      # 如果使用者還沒有 LineProfile,先建立一個空的
      line_profile = @user.line_profile || @user.create_line_profile!(
        line_user_id: "pending_#{SecureRandom.hex(8)}" # 暫時的 ID,綁定後會更新
      )

      # 產生新的綁定 token
      line_profile.generate_bind_token!

      line_profile
    end
  end
end
