module Inventory
  class SetQuantity
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
      if @quantity < 0
        @error = "數量不能是負數喔!"
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
        @error = "找不到「#{@item_name}」\n\n可以用「+#{@item_name} #{@quantity}」來新增"
        return false
      end

      # 更新數量並記錄 movement
      old_quantity = item.quantity

      ActiveRecord::Base.transaction do
        if item.update(quantity: @quantity)
          create_movement(item, old_quantity, @quantity)

          warning = @quantity <= 5 ? "\n\n⚠️ 庫存偏低,記得補貨!" : ""
          @success_message = "✅ 已設定「#{item.name}」的數量\n\n原數量: #{old_quantity}\n新數量: #{@quantity}#{warning}"
          true
        else
          @error = "設定失敗: #{item.errors.full_messages.join(', ')}"
          raise ActiveRecord::Rollback
        end
      end
    end

    def success_message
      @success_message
    end

    private

    def create_movement(item, old_quantity, new_quantity)
      # 計算實際變動量
      change = new_quantity - old_quantity

      StockMovement.create!(
        inventory_item: item,
        user: @user,
        movement_type: "set",
        quantity: change,  # 記錄變動量
        previous_quantity: old_quantity,
        new_quantity: new_quantity,
        source: @source
      )
    end
  end
end
