module Inventory
  class RemoveItem
    attr_reader :error

    def initialize(user:, item_name:, quantity:, source: "web")
      @user = user
      @item_name = item_name
      @quantity = quantity.to_i
      @source = source
      @error = nil
    end

    def call
      # 驗證數量
      if @quantity <= 0
        @error = "數量必須大於 0 喔!"
        return false
      end

      # 取得使用者的家庭
      family = @user.families.first

      unless family
        @error = "你還沒有加入任何家庭喔!\n請先到網頁版建立或加入家庭"
        return false
      end

      # 查詢庫存項目 (使用 sanitize_sql_like 防止 SQL 注入)
      sanitized_name = ActiveRecord::Base.sanitize_sql_like(@item_name)
      item = family.inventory_items.find_by("name LIKE ?", "%#{sanitized_name}%")

      unless item
        @error = "找不到「#{@item_name}」\n\n可以用「庫存」指令查看現有項目"
        return false
      end

      # 計算新數量
      old_quantity = item.quantity
      new_quantity = old_quantity - @quantity

      if new_quantity < 0
        @error = "數量不足!\n\n目前「#{item.name}」只有 #{old_quantity} 個"
        return false
      end

      # 更新數量並記錄 movement
      ActiveRecord::Base.transaction do
        if item.update(quantity: new_quantity)
          create_movement(item, old_quantity, new_quantity)

          warning = new_quantity <= 5 ? "\n\n⚠️ 庫存偏低,記得補貨!" : ""
          @success_message = "✅ 已減少「#{item.name}」\n\n原數量: #{old_quantity}\n減少: -#{@quantity}\n剩餘: #{new_quantity}#{warning}"
          true
        else
          @error = "更新失敗: #{item.errors.full_messages.join(', ')}"
          raise ActiveRecord::Rollback
        end
      end
    end

    def success_message
      @success_message
    end

    private

    def create_movement(item, old_quantity, new_quantity)
      StockMovement.create!(
        inventory_item: item,
        user: @user,
        movement_type: "remove",
        quantity: @quantity,
        previous_quantity: old_quantity,
        new_quantity: new_quantity,
        source: @source
      )
    end
  end
end
