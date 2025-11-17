Rails.application.config.middleware.use OmniAuth::Builder do
  provider :line,
    LINE_LOGIN_CONFIG[:channel_id],
    LINE_LOGIN_CONFIG[:channel_secret],
    scope: "profile openid",
    bot_prompt: "aggressive"  # 自動將使用者加為 Bot 好友
end

# 設定 OmniAuth 錯誤處理
OmniAuth.config.on_failure = proc { |env|
  OmniAuth::FailureEndpoint.new(env).redirect_to_failure
}
