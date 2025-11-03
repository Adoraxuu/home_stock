class InventoryItemsController < ApplicationController
  before_action :authenticate_user!
  before_action :set_family
  before_action :authorize_family_member
  before_action :set_inventory_item, only: [ :edit, :update, :destroy ]

  def index
    @inventory_items = @family.inventory_items.order(created_at: :desc)
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
    @family = Family.find(params[:family_id])
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
