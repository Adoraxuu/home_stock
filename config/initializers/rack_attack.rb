# 速率限制和防濫用設定
class Rack::Attack
  # 設定 Redis 快取儲存（生產環境建議使用 Redis）
  # Rack::Attack.cache.store = ActiveSupport::Cache::RedisCacheStore.new

  # 在開發環境使用記憶體快取
  Rack::Attack.cache.store = ActiveSupport::Cache::MemoryStore.new

  # 允許本地主機不受限制
  safelist("allow from localhost") do |req|
    req.ip == "127.0.0.1" || req.ip == "::1"
  end

  # 封鎖已知的惡意 IP（可以從資料庫或設定檔載入）
  # blocklist('block bad IPs') do |req|
  #   BadIp.where(ip: req.ip).exists?
  # end

  ### 防暴力破解登入 ###

  # 限制每個 IP 的登入嘗試次數
  # 每 IP 每 20 秒最多 5 次登入嘗試
  throttle("logins/ip", limit: 5, period: 20.seconds) do |req|
    if req.path == "/users/sign_in" && req.post?
      req.ip
    end
  end

  # 限制每個 email 的登入嘗試次數
  # 每 email 每分鐘最多 5 次登入嘗試
  throttle("logins/email", limit: 5, period: 1.minute) do |req|
    if req.path == "/users/sign_in" && req.post?
      # 從 POST 參數中提取 email
      req.params["user"]&.dig("email").to_s.downcase.presence
    end
  end

  ### 防註冊濫用 ###

  # 限制每個 IP 的註冊次數
  # 每 IP 每小時最多 3 次註冊
  throttle("registrations/ip", limit: 3, period: 1.hour) do |req|
    if req.path == "/users" && req.post?
      req.ip
    end
  end

  ### 防家庭成員邀請濫用 ###

  # 限制邀請成員的頻率
  # 每個使用者每分鐘最多 10 次邀請
  throttle("invitations/user", limit: 10, period: 1.minute) do |req|
    if req.path.match?(/\/families\/\d+\/family_members/) && req.post?
      # 需要從 session 或 token 中提取使用者 ID
      # 這裡使用 IP 作為簡化版本
      req.ip
    end
  end

  ### 一般 API 速率限制 ###

  # 限制每個 IP 的一般請求
  # 每 IP 每 5 分鐘最多 300 次請求
  throttle("req/ip", limit: 300, period: 5.minutes) do |req|
    req.ip unless req.path.start_with?("/assets")
  end

  ### 自訂回應 ###

  # 當請求被限制時的回應
  self.throttled_responder = lambda do |env|
    match_data = env["rack.attack.match_data"]
    now = match_data[:epoch_time]

    headers = {
      "RateLimit-Limit" => match_data[:limit].to_s,
      "RateLimit-Remaining" => "0",
      "RateLimit-Reset" => (now + (match_data[:period] - now % match_data[:period])).to_s
    }

    [ 429, headers, [ "請求過於頻繁，請稍後再試。\n" ] ]
  end

  # 記錄被封鎖的請求
  ActiveSupport::Notifications.subscribe("rack.attack") do |name, start, finish, request_id, payload|
    req = payload[:request]

    if [ :throttle, :blocklist ].include?(req.env["rack.attack.match_type"])
      Rails.logger.warn("[Rack::Attack] #{req.env['rack.attack.match_type']} #{req.ip} #{req.request_method} #{req.fullpath}")
    end
  end
end
