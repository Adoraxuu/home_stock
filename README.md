# Home Stock 家庭庫存管理系統

一個簡單易用的家庭庫存管理系統，幫助家庭成員共同管理和追蹤家中物品庫存。

## 主要功能

- 用戶註冊與登入（使用 Devise）
- 建立與管理家庭群組
- 邀請家庭成員加入
- 新增、編輯、刪除庫存物品
- 依照品牌、類別篩選物品
- 低庫存提醒功能

## 技術棧

- **Ruby**: 3.4.3
- **Rails**: 8.0.3
- **Database**: PostgreSQL
- **Frontend**:
  - Tailwind CSS
  - Hotwire (Turbo & Stimulus)
  - Importmap
- **Authentication**: Devise
- **Background Jobs**: Solid Queue
- **Caching**: Solid Cache
- **Deployment**: Docker + Kamal

## 系統需求

- Ruby 3.4.3
- PostgreSQL
- Node.js (for asset compilation)

## 安裝步驟

1. Clone 專案
```bash
git clone <repository-url>
cd home_stock
```

2. 安裝相依套件
```bash
bundle install
```

3. 設定資料庫
```bash
# 建立 config/database.yml 並設定 PostgreSQL 連線資訊
cp config/database.yml.example config/database.yml

# 建立資料庫
rails db:create

# 執行遷移
rails db:migrate
```

4. 啟動開發伺服器
```bash
bin/dev
```

或分別啟動：
```bash
# Rails server
rails server

# Tailwind CSS
rails tailwindcss:watch
```

應用程式將運行在 `http://localhost:3000`

## 資料庫結構

### Users（使用者）
- Devise 管理的使用者帳號

### Families（家庭）
- 家庭群組資訊
- 由建立者（creator）擁有

### FamilyMembers（家庭成員）
- 連接使用者與家庭的中間表

### InventoryItems（庫存物品）
- 儲存物品資訊（名稱、品牌、類別、數量等）
- 屬於特定家庭

## 開發

### 執行測試
```bash
rails test
```

### Code Linting
```bash
rubocop
```

### 安全檢查
```bash
brakeman
```

## 部署

本專案支援使用 Kamal 進行 Docker 部署：

```bash
kamal setup
kamal deploy
```

詳細部署說明請參考 [Kamal 文件](https://kamal-deploy.org/)

## License

All rights reserved.
