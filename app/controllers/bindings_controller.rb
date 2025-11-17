class BindingsController < ApplicationController
  before_action :authenticate_user!

  def show
    @line_profile = current_user.line_profile

    # 如果已經綁定,顯示綁定資訊
    return if @line_profile&.bound?

    # 如果還沒綁定,產生新的 token
    service = Users::GenerateBindToken.new(current_user)
    @line_profile = service.call
  end

  def create
    service = Users::GenerateBindToken.new(current_user)
    @line_profile = service.call

    redirect_to binding_path, notice: "已產生新的綁定碼"
  end

  def destroy
    current_user.line_profile&.destroy
    redirect_to binding_path, notice: "已解除 LINE 綁定"
  end
end
