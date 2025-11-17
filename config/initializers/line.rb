# LINE Messaging API 設定
LINE_CONFIG = {
  channel_id: Rails.application.credentials.dig(:line, :channel_id),
  channel_secret: Rails.application.credentials.dig(:line, :channel_secret),
  channel_token: Rails.application.credentials.dig(:line, :channel_access_token)
}.freeze

# LINE Login 設定
LINE_LOGIN_CONFIG = {
  channel_id: Rails.application.credentials.dig(:line_login, :channel_id),
  channel_secret: Rails.application.credentials.dig(:line_login, :channel_secret)
}.freeze

if Rails.env.production?
  if LINE_CONFIG[:channel_id].blank? || LINE_CONFIG[:channel_secret].blank? || LINE_CONFIG[:channel_token].blank?
    Rails.logger.warn "LINE Messaging API credentials are not configured. LINE Bot features will not work."
  end

  if LINE_LOGIN_CONFIG[:channel_id].blank? || LINE_LOGIN_CONFIG[:channel_secret].blank?
    Rails.logger.warn "LINE Login credentials are not configured. LINE Login binding will not work."
  end
end
