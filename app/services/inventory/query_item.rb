module Inventory
  class QueryItem
    attr_reader :error

    def initialize(user:, item_name:)
      @user = user
      @item_name = item_name
      @error = nil
    end

    def call
      # 取得使用者的家庭
      family = @user.families.first

      unless family
        @error = "你還沒有加入任何家庭喔!\n請先到網頁版建立或加入家庭"
        return nil
      end

      # 查詢庫存項目 (使用 sanitize_sql_like 防止 SQL 注入)
      sanitized_name = ActiveRecord::Base.sanitize_sql_like(@item_name)
      items = family.inventory_items.where("name LIKE ?", "%#{sanitized_name}%")

      if items.empty?
        @error = "找不到「#{@item_name}」相關的庫存項目"
        return nil
      end

      items
    end

    def format_response(items)
      return @error if @error

      if items.size == 1
        item = items.first
        <<~TEXT
          📦 #{item.name}

          品牌: #{item.brand}
          分類: #{item.category}
          數量: #{item.quantity}
          #{item.quantity <= 5 ? "⚠️ 庫存偏低!" : ""}
        TEXT
      else
        result = "找到 #{items.size} 個相關項目:\n\n"
        items.each do |item|
          status = item.quantity <= 5 ? " ⚠️" : ""
          result += "• #{item.name} (#{item.brand}) - #{item.quantity}#{status}\n"
        end
        result
      end
    end
  end
end
