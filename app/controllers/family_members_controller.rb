class FamilyMembersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_family
  before_action :authorize_family_owner, only: [ :create, :destroy ]

  def create
    # 透過 email 查找使用者
    user = User.find_by(email: params[:email])

    # 統一錯誤訊息，避免用戶枚舉攻擊
    if user.nil? || @family.users.include?(user)
      # 使用模糊的錯誤訊息，不洩漏用戶是否存在
      redirect_to @family, alert: "無法新增此成員，請確認 email 是否正確。"
      # 記錄安全事件
      Rails.logger.warn("Failed member invitation attempt for family #{@family.id}: #{params[:email]}")
      return
    end

    family_member = @family.family_members.build(user: user, role: "member")

    if family_member.save
      redirect_to @family, notice: "成員新增成功！"
      # 記錄成功事件
      Rails.logger.info("User #{user.id} added to family #{@family.id} by user #{current_user.id}")
    else
      redirect_to @family, alert: "新增成員失敗，請稍後再試。"
      Rails.logger.warn("Failed to add user #{user.id} to family #{@family.id}: #{family_member.errors.full_messages}")
    end
  end

  def destroy
    family_member = @family.family_members.find(params[:id])

    # 防止刪除擁有者
    if family_member.role == "owner"
      redirect_to @family, alert: "無法移除家庭擁有者。"
      return
    end

    family_member.destroy
    redirect_to @family, notice: "成員已移除。"
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

  def authorize_family_owner
    unless @family.owner?(current_user)
      redirect_to @family, alert: "只有家庭擁有者可以管理成員。"
    end
  end
end
