Rails.application.routes.draw do
  # Devise 使用者認證
  devise_for :users

  # 首頁
  root "home#index"

  # LINE 綁定
  resource :binding, only: [ :show, :create, :destroy ]

  # LINE Webhook
  namespace :line do
    post "webhook", to: "webhooks#callback"
  end

  # 家庭管理
  resources :families do
    # 家庭成員
    resources :family_members, only: [ :create, :destroy ]
    # 庫存項目（巢狀在家庭下）
    resources :inventory_items
  end

  # 健康檢查
  get "up" => "rails/health#show", as: :rails_health_check

  # Render dynamic PWA files from app/views/pwa/*
  # get "manifest" => "rails/pwa#manifest", as: :pwa_manifest
  # get "service-worker" => "rails/pwa#service_worker", as: :pwa_service_worker
end
