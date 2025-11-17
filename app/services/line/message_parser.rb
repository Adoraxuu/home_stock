module Line
  class MessageParser
    BIND_PATTERN = /^綁定\s+([A-Z0-9]{6})$/
    ADD_PATTERNS = [/^\+(.+?)\s+(\d+)$/, /^新增\s+(.+?)\s+(\d+)$/]
    REMOVE_PATTERNS = [/^\-(.+?)\s+(\d+)$/, /^用掉\s+(.+?)\s+(\d+)$/]
    SET_PATTERN = /^設\s+(.+?)\s+(\d+)$/
    QUERY_PATTERN = /^查\s+(.+)$/
    LIST_PATTERN = /^庫存$/

    def initialize(text)
      @text = text.strip
    end

    def parse
      # 綁定指令
      if match = @text.match(BIND_PATTERN)
        return { action: :bind, token: match[1] }
      end

      # 新增指令
      ADD_PATTERNS.each do |pattern|
        if match = @text.match(pattern)
          return { action: :add, name: match[1].strip, quantity: match[2].to_i }
        end
      end

      # 減少指令
      REMOVE_PATTERNS.each do |pattern|
        if match = @text.match(pattern)
          return { action: :remove, name: match[1].strip, quantity: match[2].to_i }
        end
      end

      # 設定指令
      if match = @text.match(SET_PATTERN)
        return { action: :set, name: match[1].strip, quantity: match[2].to_i }
      end

      # 查詢指令
      if match = @text.match(QUERY_PATTERN)
        return { action: :query, name: match[1].strip }
      end

      # 列表指令
      if @text.match(LIST_PATTERN)
        return { action: :list }
      end

      # 無法識別的指令
      { action: :unknown, text: @text }
    end
  end
end
