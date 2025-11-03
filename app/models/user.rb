class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # 關聯
  has_many :family_members, dependent: :destroy
  has_many :families, through: :family_members
  has_many :created_families, class_name: "Family", foreign_key: "creator_id", dependent: :destroy

  # 驗證
  validates :name, presence: true
end
