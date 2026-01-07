#!/bin/bash
# 從 RDS 遷移資料到 EC2 本地 PostgreSQL
# 使用方式：在 EC2 上執行此腳本

set -e

# ============================================
# 設定區域 - 請根據你的環境修改
# ============================================
RDS_HOST="your-rds-endpoint.rds.amazonaws.com"
RDS_PORT="5432"
RDS_USER="your_rds_user"
RDS_DB="home_stock_production"

# 本地 PostgreSQL (Docker Compose)
LOCAL_CONTAINER="home_stock_db"
LOCAL_USER="home_stock"
LOCAL_DB="home_stock_production"

BACKUP_FILE="/tmp/rds_backup_$(date +%Y%m%d_%H%M%S).sql"

# ============================================
# 步驟 1：從 RDS 匯出資料
# ============================================
echo "📦 步驟 1/4：從 RDS 匯出資料..."
echo "請輸入 RDS 密碼："

pg_dump -h "$RDS_HOST" -p "$RDS_PORT" -U "$RDS_USER" -d "$RDS_DB" \
  --no-owner --no-acl \
  -F c -f "$BACKUP_FILE"

echo "✅ 備份完成：$BACKUP_FILE"
echo "   檔案大小：$(du -h "$BACKUP_FILE" | cut -f1)"

# ============================================
# 步驟 2：確認本地 PostgreSQL 運行中
# ============================================
echo ""
echo "🔍 步驟 2/4：確認本地 PostgreSQL 運行中..."

if ! docker ps | grep -q "$LOCAL_CONTAINER"; then
  echo "❌ 錯誤：找不到運行中的 $LOCAL_CONTAINER 容器"
  echo "請先執行：docker compose -f ~/docker-compose.yml up -d db"
  exit 1
fi

echo "✅ PostgreSQL 容器運行中"

# ============================================
# 步驟 3：複製備份檔到容器
# ============================================
echo ""
echo "📋 步驟 3/4：複製備份檔到容器..."

docker cp "$BACKUP_FILE" "$LOCAL_CONTAINER:/tmp/backup.sql"
echo "✅ 備份檔已複製到容器"

# ============================================
# 步驟 4：還原資料
# ============================================
echo ""
echo "🔄 步驟 4/4：還原資料到本地 PostgreSQL..."
echo "⚠️  警告：這將清除現有資料！"
read -p "確定要繼續嗎？(y/N): " confirm

if [ "$confirm" != "y" ] && [ "$confirm" != "Y" ]; then
  echo "已取消"
  exit 0
fi

# 停止 web 容器避免連線衝突
echo "暫停 web 容器..."
docker stop home_stock 2>/dev/null || true

# 重建資料庫
docker exec "$LOCAL_CONTAINER" dropdb -U "$LOCAL_USER" "$LOCAL_DB" --if-exists
docker exec "$LOCAL_CONTAINER" createdb -U "$LOCAL_USER" "$LOCAL_DB"

# 還原資料
docker exec "$LOCAL_CONTAINER" pg_restore -U "$LOCAL_USER" -d "$LOCAL_DB" \
  --no-owner --no-acl /tmp/backup.sql

echo "✅ 資料還原完成！"

# 重新啟動 web 容器
echo "重新啟動 web 容器..."
docker compose -f ~/docker-compose.yml up -d

# 清理
rm -f "$BACKUP_FILE"
docker exec "$LOCAL_CONTAINER" rm -f /tmp/backup.sql

echo ""
echo "🎉 遷移完成！"
echo "請執行以下指令確認資料："
echo "  docker exec -it $LOCAL_CONTAINER psql -U $LOCAL_USER -d $LOCAL_DB -c '\\dt'"
