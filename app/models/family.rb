class Family < ApplicationRecord
  # 關聯
  belongs_to :creator, class_name: "User"
  has_many :family_members, dependent: :destroy
  has_many :users, through: :family_members
  has_many :inventory_items, dependent: :destroy

  # 驗證
  validates :name, presence: true

  # 檢查使用者是否為此家庭的擁有者
  def owner?(user)
    creator_id == user.id
  end

  # 檢查使用者是否為此家庭的成員
  def member?(user)
    users.include?(user) || owner?(user)
  end
end
