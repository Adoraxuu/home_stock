# 設定額外的安全標頭
Rails.application.config.action_dispatch.default_headers.merge!({
  # 防止 MIME 類型嗅探
  "X-Content-Type-Options" => "nosniff",

  # 防止點擊劫持 (Clickjacking)
  "X-Frame-Options" => "DENY",

  # XSS 保護（現代瀏覽器已內建，但為了向後相容仍建議設定）
  "X-XSS-Protection" => "1; mode=block",

  # 強制 HTTPS（僅在生產環境）
  # 'Strict-Transport-Security' => 'max-age=31536000; includeSubDomains' # 在生產環境啟用

  # Referrer Policy - 控制 Referer 標頭的發送
  "Referrer-Policy" => "strict-origin-when-cross-origin",

  # Permissions Policy - 控制瀏覽器功能的存取
  "Permissions-Policy" => "geolocation=(), microphone=(), camera=()"
})

# 在生產環境啟用 HSTS
if Rails.env.production?
  Rails.application.config.action_dispatch.default_headers.merge!({
    "Strict-Transport-Security" => "max-age=31536000; includeSubDomains; preload"
  })
end
