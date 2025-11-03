class FamiliesController < ApplicationController
  before_action :authenticate_user!
  before_action :set_family, only: [ :show, :edit, :update, :destroy ]
  before_action :authorize_family_access, only: [ :show, :edit, :update ]
  before_action :authorize_family_owner, only: [ :destroy ]

  def index
    @families = current_user.families
  end

  def show
    @inventory_items = @family.inventory_items.order(created_at: :desc)
    @family_members = @family.family_members.includes(:user)
  end

  def new
    @family = Family.new
  end

  def create
    @family = Family.new(family_params)
    @family.creator = current_user

    if @family.save
      # 自動加入創建者為成員
      @family.family_members.create(user: current_user, role: "owner")
      redirect_to @family, notice: "家庭帳號建立成功！"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @family.update(family_params)
      redirect_to @family, notice: "家庭資訊更新成功！"
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @family.destroy
    redirect_to families_url, notice: "家庭帳號已刪除。"
  end

  private

  def set_family
    @family = Family.find(params[:id])
  end

  def authorize_family_access
    unless @family.member?(current_user)
      redirect_to families_path, alert: "您沒有權限存取此家庭。"
    end
  end

  def authorize_family_owner
    unless @family.owner?(current_user)
      redirect_to @family, alert: "只有家庭擁有者可以刪除家庭。"
    end
  end

  def family_params
    params.require(:family).permit(:name)
  end
end
