class LineProfile < ApplicationRecord
  belongs_to :user

  # 驗證
  validates :line_user_id, presence: true, uniqueness: true
  validates :bind_token, uniqueness: true, allow_nil: true

  # 產生綁定 token
  def generate_bind_token!
    self.bind_token = SecureRandom.alphanumeric(6).upcase
    self.bind_token_expires_at = 30.minutes.from_now
    save!
  end

  # 檢查 token 是否有效
  def valid_bind_token?(token)
    bind_token == token && bind_token_expires_at && bind_token_expires_at > Time.current
  end

  # 清除綁定 token
  def clear_bind_token!
    update!(bind_token: nil, bind_token_expires_at: nil)
  end

  # 檢查是否已綁定使用者
  def bound?
    user_id.present?
  end
end
