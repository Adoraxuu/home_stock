module Inventory
  class ListItems
    attr_reader :error

    def initialize(user:)
      @user = user
      @error = nil
    end

    def call
      # 取得使用者的家庭
      family = @user.families.first

      unless family
        @error = "你還沒有加入任何家庭喔!\n請先到網頁版建立或加入家庭"
        return nil
      end

      # 取得所有庫存項目,按分類排序
      items = family.inventory_items.order(:category, :name)

      if items.empty?
        @error = "目前還沒有任何庫存項目\n\n可以用以下指令新增:\n+品名 數量"
        return nil
      end

      items
    end

    def format_response(items)
      return @error if @error

      # 按分類分組
      grouped_items = items.group_by(&:category)

      result = "📦 家庭庫存清單\n"
      result += "=" * 20 + "\n\n"

      grouped_items.each do |category, category_items|
        result += "【#{category}】\n"
        category_items.each do |item|
          # 簡化顯示,只在數量偏低時加警告
          warning = item.quantity <= 5 ? " ⚠️" : ""
          brand_info = item.brand != "未分類" ? " (#{item.brand})" : ""
          result += "• #{item.name}#{brand_info} - #{item.quantity}#{warning}\n"
        end
        result += "\n"
      end

      # 統計資訊
      total_items = items.size
      low_stock_count = items.select { |i| i.quantity <= 5 }.size

      result += "=" * 20 + "\n"
      result += "總共 #{total_items} 項"
      result += " | #{low_stock_count} 項偏低" if low_stock_count > 0

      result
    end
  end
end
