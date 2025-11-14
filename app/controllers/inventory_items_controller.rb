class InventoryItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_family
  before_action :authorize_family_member
  before_action :set_inventory_item, only: [ :edit, :update, :destroy ]

  def index
    @inventory_items = @family.inventory_items.order(created_at: :desc)

    # 搜尋功能
    if params[:search].present?
      # 轉義 LIKE 特殊字符，防止 LIKE 注入
      sanitized_search = sanitize_sql_like(params[:search])
      search_term = "%#{sanitized_search}%"
      @inventory_items = @inventory_items.where(
        "brand ILIKE ? OR name ILIKE ?",
        search_term, search_term
      )
    end

    # 種類篩選
    if params[:category].present?
      @inventory_items = @inventory_items.by_category(params[:category])
    end

    # 品牌篩選
    if params[:brand].present?
      @inventory_items = @inventory_items.by_brand(params[:brand])
    end

    # 取得所有品牌和種類供篩選使用
    @brands = @family.inventory_items.distinct.pluck(:brand).compact.sort
    @categories = @family.inventory_items.distinct.pluck(:category).compact.sort

    # 統計資料
    @low_stock_count = @family.inventory_items.low_stock.count
    @category_stats = @family.inventory_items.group(:category).count
  end

  def new
    @inventory_item = @family.inventory_items.build
  end

  def create
    @inventory_item = @family.inventory_items.build(inventory_item_params)

    if @inventory_item.save
      redirect_to family_path(@family), notice: "庫存項目新增成功！"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @inventory_item.update(inventory_item_params)
      redirect_to family_path(@family), notice: "庫存項目更新成功！"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @inventory_item.destroy
    redirect_to family_path(@family), notice: "庫存項目已刪除。"
  end

  private

  def set_family
    # 只允許存取使用者所屬的家庭，防止 IDOR 攻擊
    @family = current_user.families.find_by(id: params[:family_id]) ||
              current_user.created_families.find_by(id: params[:family_id])

    unless @family
      redirect_to families_path, alert: "您沒有權限存取此家庭。"
      Rails.logger.warn("IDOR attempt: User #{current_user.id} tried to access family #{params[:family_id]}")
    end
  end

  def set_inventory_item
    @inventory_item = @family.inventory_items.find(params[:id])
  end

  def authorize_family_member
    unless @family.member?(current_user)
      redirect_to families_path, alert: "您沒有權限存取此家庭的庫存。"
    end
  end

  def inventory_item_params
    params.require(:inventory_item).permit(:brand, :name, :category, :quantity, :unit, :notes)
  end
end
