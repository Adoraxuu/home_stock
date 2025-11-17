module Inventory
  class AddItem
    attr_reader :error

    def initialize(user:, item_name:, quantity:)
      @user = user
      @item_name = item_name
      @quantity = quantity.to_i
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

      # 檢查是否已存在同名項目 (使用 sanitize_sql_like 防止 SQL 注入)
      sanitized_name = ActiveRecord::Base.sanitize_sql_like(@item_name)
      existing_item = family.inventory_items.find_by("name LIKE ?", "%#{sanitized_name}%")

      if existing_item
        # 增加現有項目的數量
        old_quantity = existing_item.quantity
        new_quantity = old_quantity + @quantity
        if existing_item.update(quantity: new_quantity)
          @success_message = "✅ 已增加「#{existing_item.name}」\n\n原數量: #{old_quantity}\n增加: +#{@quantity}\n新數量: #{new_quantity}"
          true
        else
          @error = "更新失敗: #{existing_item.errors.full_messages.join(', ')}"
          false
        end
      else
        # 建立新項目 (預設分類和品牌)
        item = family.inventory_items.create(
          name: @item_name,
          quantity: @quantity,
          brand: "未分類",
          category: "其他"
        )

        if item.persisted?
          @success_message = "✅ 已新增「#{@item_name}」\n\n數量: #{@quantity}\n\n💡 可以到網頁版設定品牌和分類"
          true
        else
          @error = "新增失敗: #{item.errors.full_messages.join(', ')}"
          false
        end
      end
    end

    def success_message
      @success_message
    end
  end
end
