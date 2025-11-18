class StockMovement < ApplicationRecord
  # 關聯
  belongs_to :inventory_item
  belongs_to :user

  # 驗證
  validates :movement_type, presence: true, inclusion: { in: %w[add remove set adjust] }
  validates :quantity, presence: true, numericality: true
  validates :previous_quantity, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :new_quantity, presence: true, numericality: { greater_than_or_equal_to: 0 }
  validates :source, inclusion: { in: %w[web line_bot api], allow_nil: true }

  # 範圍查詢
  scope :recent, -> { order(created_at: :desc) }
  scope :by_type, ->(type) { where(movement_type: type) }
  scope :by_source, ->(source) { where(source: source) }
  scope :for_item, ->(item_id) { where(inventory_item_id: item_id) }

  # 格式化顯示
  def formatted_change
    case movement_type
    when "add"
      "+#{quantity}"
    when "remove"
      "-#{quantity}"
    when "set"
      "→ #{new_quantity}"
    when "adjust"
      quantity >= 0 ? "+#{quantity}" : quantity.to_s
    end
  end

  def description
    "#{inventory_item.name}: #{previous_quantity} #{formatted_change} = #{new_quantity}"
  end
end
