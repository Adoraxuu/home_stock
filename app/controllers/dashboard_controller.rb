class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @line_profile = current_user.line_profile
    @families = current_user.families.includes(:inventory_items)

    # 取得最近的庫存變動記錄
    family_ids = @families.pluck(:id)
    @recent_movements = StockMovement
      .joins(:inventory_item)
      .where(inventory_items: { family_id: family_ids })
      .includes(:inventory_item, :user)
      .recent
      .limit(10)

    # 統計資訊
    @total_items = InventoryItem.where(family_id: family_ids).count
    @low_stock_items = InventoryItem.where(family_id: family_ids).low_stock.count
    @movements_today = StockMovement
      .joins(:inventory_item)
      .where(inventory_items: { family_id: family_ids })
      .where("stock_movements.created_at >= ?", Time.current.beginning_of_day)
      .count
  end

  def movements
    @family = current_user.families.find(params[:family_id]) if params[:family_id]

    movements_query = StockMovement
      .joins(:inventory_item)
      .includes(:inventory_item, :user)
      .recent

    if @family
      movements_query = movements_query.where(inventory_items: { family_id: @family.id })
    else
      family_ids = current_user.families.pluck(:id)
      movements_query = movements_query.where(inventory_items: { family_id: family_ids })
    end

    # 篩選條件
    movements_query = movements_query.by_type(params[:type]) if params[:type].present?
    movements_query = movements_query.by_source(params[:source]) if params[:source].present?

    @movements = movements_query.limit(50)
    @families = current_user.families
  end
end
