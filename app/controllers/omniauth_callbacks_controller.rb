class OmniauthCallbacksController < ApplicationController
  before_action :authenticate_user!

  def line
    auth = request.env["omniauth.auth"]

    # 取得 LINE 使用者資訊
    line_user_id = auth["uid"]
    info = auth["info"]

    # 檢查此 LINE 帳號是否已經綁定其他使用者
    existing_profile = LineProfile.find_by(line_user_id: line_user_id)
    if existing_profile && existing_profile.user_id != current_user.id
      redirect_to binding_path, alert: "此 LINE 帳號已經綁定其他使用者"
      return
    end

    # 建立或更新 LineProfile
    line_profile = current_user.line_profile || current_user.build_line_profile

    line_profile.update!(
      line_user_id: line_user_id,
      display_name: info["name"],
      picture_url: info["image"],
      status_message: info["description"]
    )

    redirect_to binding_path, notice: "LINE 帳號綁定成功!👌"
  rescue StandardError => e
    Rails.logger.error "LINE OAuth callback error: #{e.message}"
    redirect_to binding_path, alert: "綁定失敗: #{e.message}"
  end

  def failure
    redirect_to binding_path, alert: "LINE 登入失敗,請重試"
  end
end
