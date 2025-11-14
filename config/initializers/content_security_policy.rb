# Be sure to restart your server when you modify this file.

# Define an application-wide content security policy.
# See the Securing Rails Applications Guide for more information:
# https://guides.rubyonrails.org/security.html#content-security-policy-header

Rails.application.configure do
  config.content_security_policy do |policy|
    policy.default_src :self, :https
    policy.font_src    :self, :https, :data
    policy.img_src     :self, :https, :data
    policy.object_src  :none
    # 允許 importmap 和內嵌腳本（使用 nonce）
    policy.script_src  :self, :https
    # 允許 Tailwind CSS 和內嵌樣式（使用 nonce）
    policy.style_src   :self, :https, :unsafe_inline  # Tailwind 需要 unsafe-inline
    policy.connect_src :self, :https
    policy.frame_ancestors :none  # 防止被嵌入 iframe (Clickjacking 防護)
    policy.base_uri    :self
    policy.form_action :self

    # 在開發環境中允許更寬鬆的設定
    if Rails.env.development?
      policy.connect_src :self, :https, "ws://localhost:*", "http://localhost:*"
    end

    # Specify URI for violation reports (可選)
    # policy.report_uri "/csp-violation-report-endpoint"
  end

  # Generate session nonces for permitted importmap, inline scripts, and inline styles.
  config.content_security_policy_nonce_generator = ->(request) { request.session.id.to_s }
  config.content_security_policy_nonce_directives = %w[script-src]

  # 在生產環境強制執行，開發環境僅報告
  if Rails.env.development?
    config.content_security_policy_report_only = true
  end
end
