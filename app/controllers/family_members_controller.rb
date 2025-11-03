class FamilyMembersController < ApplicationController
  before_action :authenticate_user!
  before_action :set_family
  before_action :authorize_family_owner, only: [ :create, :destroy ]

  def create
    # 透過 email 查找使用者
    user = User.find_by(email: params[:email])

    if user.nil?
      redirect_to @family, alert: "找不到此 email 的使用者。"
      return
    end

    if @family.users.include?(user)
      redirect_to @family, alert: "此使用者已是家庭成員。"
      return
    end

    family_member = @family.family_members.build(user: user, role: "member")

    if family_member.save
      redirect_to @family, notice: "成員新增成功！"
    else
      redirect_to @family, alert: "新增成員失敗：#{family_member.errors.full_messages.join(', ')}"
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
    @family = Family.find(params[:family_id])
  end

  def authorize_family_owner
    unless @family.owner?(current_user)
      redirect_to @family, alert: "只有家庭擁有者可以管理成員。"
    end
  end
end
