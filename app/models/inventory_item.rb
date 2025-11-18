class InventoryItem < ApplicationRecord
  # 關聯
  belongs_to :family
  has_many :stock_movements, dependent: :destroy

  # 驗證
  validates :name, presence: true
  validates :quantity, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :brand, presence: true
  validates :category, presence: true

  # 範圍查詢
  scope :by_category, ->(category) { where(category: category) }
  scope :by_brand, ->(brand) { where(brand: brand) }
  scope :low_stock, -> { where("quantity <= ?", 5) }
end
