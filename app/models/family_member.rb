class FamilyMember < ApplicationRecord
  # 關聯
  belongs_to :user
  belongs_to :family

  # 驗證
  validates :user_id, uniqueness: { scope: :family_id, message: "已經是該家庭的成員" }
  validates :role, inclusion: { in: %w[owner member], message: "%{value} 不是有效的角色" }

  # 預設值
  after_initialize :set_default_role, if: :new_record?

  private

  def set_default_role
    self.role ||= "member"
  end
end
